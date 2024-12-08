extends MarginContainer

@onready var songElementButton : Button = $SongElementButton
@onready var main : Control = $"../../../../../../../../../../.."
@onready var song_thumbnail_texture_rect: TextureRect = $Panel/MarginContainer/HBoxContainer/MarginContainer/PanelContainer/Panel/songThumbnailTextureRect
@onready var song_thumbnail_panel_container: PanelContainer = $Panel/MarginContainer/HBoxContainer/MarginContainer/PanelContainer/Panel/songThumbnailTextureRect/songThumbnailPanelContainer
@export var songFileName : String = "" # example: "author - song title.mp3"
@export var songFileNamePath : String = "" # example: "C:\user\desktop\musicfolder\author - song title.mp3"
@export var songFileNameDir : String = " " # example: "C:\user\desktop\musicfolder\"

var currentSongTimestamp: float = 0.0

var playing : bool = false

var hover : bool = false

var songMetadataExtractor: MusicMetadata = MusicMetadata.new()

var songFileData: PackedByteArray = []

var setCardInfosThread: Thread = Thread.new()

signal songElementSelected(songElementNode : Node, songFileName : String, songFileNamePath : String, songFileNameDir : String, songAuthor : String, songTitle : String, songTotalDuration : String, songCurrentTimestamp: float, songMetadata: Dictionary[String, Variant])

signal infoImportCompleted()

var songInfo: Dictionary[String, Variant] = {
	"title": "",
	"artist": "",
	"album": "",
	"album_artist": "",
	"lyricist": "",
	"genre": "",
	"year": 0,
	"date": "",
	"release_label": "",
	"copyright": "",
	"isrc": "",
	"comments": "",
	"user": "",
	"mood": "",
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	songElementSelected.connect(main.songElementSelectedFunction)
	#connect("songElementSelected", Callable(main, "songElementSelectedFunction"))
	pivot_offset = size / 2.0
	$Panel.pivot_offset = $Panel.size / 2.0
	songElementButton.pivot_offset = songElementButton.size / 2.0
	
	setCardInfosThread.start(setCardInfosThreaded, Thread.PRIORITY_HIGH)

func setCardInfosThreaded() -> void:
	songFileData = FileAccess.get_file_as_bytes(songFileNamePath)
	
	# Estraiamo i metadati
	songInfo["title"] = get_title(songFileData)
	songInfo["artist"] = get_artist(songFileData)
	songInfo["album"] = get_album(songFileData)
	songInfo["album_artist"] = get_album_artist(songFileData)
	songInfo["lyricist"] = get_lyricist(songFileData)
	songInfo["genre"] = get_genre(songFileData)
	songInfo["year"] = get_year(songFileData)
	songInfo["date"] = get_date(songFileData) if get_date(songFileData) else get_date_alt(songFileData)
	songInfo["release_label"] = get_release_label(songFileData)
	songInfo["copyright"] = get_copyright(songFileData)
	songInfo["isrc"] = get_isrc(songFileData)
	songInfo["comments"] = get_comments(songFileData)
	songInfo["user"] = get_user(songFileData)
	songInfo["mood"] = get_mood(songFileData)
	
	# Estraiamo e processiamo la cover
	var cover_data: Dictionary = get_cover(songFileData)
	var image: Image
	
	if !cover_data.is_empty():
		image = create_image_from_cover_data(cover_data)
		if image:
			image.resize(400, 400, Image.INTERPOLATE_LANCZOS)
			image.compress(Image.COMPRESS_BPTC, Image.COMPRESS_SOURCE_GENERIC)
			var texture: Texture2D = ImageTexture.create_from_image(image)
			song_thumbnail_texture_rect.set_deferred("texture", texture)
	
	# Impostiamo i metadati nell'interfaccia
	call_deferred("setTitle", songInfo["title"] if songInfo["title"] else songFileName)
	call_deferred("setAuthor", songInfo["artist"] if songInfo["artist"] else songInfo["album_artist"])
	
	call_deferred("thread_completed_info_import")

func thread_completed_info_import() -> void:
	setCardInfosThread.wait_to_finish()
	infoImportCompleted.emit()

#region Metadata Parsing Region
# Funzione per interpretare i byte unsynchsafe
func unsynchsafe(buffer: PackedByteArray) -> int:
	return (buffer[0] << 21) | (buffer[1] << 14) | (buffer[2] << 7) | buffer[3]

func read_id3v2_header(data: PackedByteArray) -> Dictionary:
	var header := {
		"version": 0,
		"revision": 0,
		"flags": 0,
		"size": 0,
		"valid": false
	}
	
	if data.size() < 10:
		print("File troppo piccolo per contenere un header ID3")
		return header
		
	var id3_header: PackedByteArray = data.slice(0, 10)
	if id3_header.slice(0, 3).get_string_from_ascii() != "ID3":
		print("Non è un file ID3")
		return header
		
	header.version = id3_header[3]
	header.revision = id3_header[4]
	header.flags = id3_header[5]
	header.size = unsynchsafe(id3_header.slice(6, 10))
	header.valid = true
	
	print("ID3v2.", header.version, ".", header.revision, " flags:", header.flags, " size:", header.size)
	return header

func read_frame(data: PackedByteArray, frame_id: String) -> PackedByteArray:
	var pos: int = 10
	var header := read_id3v2_header(data)
	var unsync: bool = header.flags & 0x80 > 0
	
	while pos < data.size():
		var frame_header: PackedByteArray = data.slice(pos, pos + 10)
		var id: String = frame_header.slice(0, 4).get_string_from_ascii()
		# Gestione speciale per APIC e controllo sync-safe
		var Size: int = unsynchsafe(frame_header.slice(4, 8))
		if Size > 0x7f and id == "APIC":
			Size = (frame_header[4] << 24) | (frame_header[5] << 16) | (frame_header[6] << 8) | frame_header[7]
		
		# HACK: Uncomment This If You Need Debugging On What Tags Were Found.
		#print(id)
		
		pos += 10
		if id == frame_id:
			var frame_data := data.slice(pos, pos + Size)
			# Applica desincronizzazione se necessario
			if unsync:
				frame_data = unsynchronize(frame_data)
			return frame_data
		pos += Size
	return PackedByteArray()

func unsynchronize(data: PackedByteArray) -> PackedByteArray:
	var result := PackedByteArray()
	var i := 0
	while i < data.size():
		result.append(data[i])
		if data[i] == 0xFF and i + 1 < data.size() and data[i + 1] == 0x00:
			i += 1
		i += 1
	return result

func get_rating(data: PackedByteArray) -> int:
	# Prova a cercare il frame POPM per la classificazione
	var rating_frame: PackedByteArray = read_frame(data, "POPM")
	
	print("Contenuto frame POPM:", rating_frame)
	
	if rating_frame.size() > 0:
		print("Contenuto frame POPM:", rating_frame)
		return int(rating_frame[0])  # Primo byte del frame POPM
	
	# Se il frame POPM non è presente, prova a cercare nei frame TXXX
	print("Frame POPM non presente, si procede a cercare nei frame TXXX")
	var pos: int = 10  # Inizia subito dopo l'header ID3v2
	while pos < data.size():
		var frame_header: PackedByteArray = data.slice(pos, pos + 10)
		var id: String = frame_header.slice(0, 4).get_string_from_ascii()
		var Size: int = unsynchsafe(frame_header.slice(4, 8))
		pos += 10
		
		if id == "TXXX":
			# Legge il contenuto del frame TXXX
			var txxx_content: PackedByteArray = data.slice(pos, pos + Size)
			var description: String = txxx_content.get_string_from_ascii()
			
			# Se la descrizione contiene "RATING" o "CLASSIFICATION"
			if description.find("RATING") != -1 or description.find("CLASSIFICATION") != -1:
				# Ritorna il primo byte dopo la descrizione come rating
				print("Frame TXXX con RATING trovato:", txxx_content)
				return int(txxx_content[description.length() + 1])  # Valore dopo la descrizione
		
		pos += Size  # Passa al prossimo frame

	# Nessuna classificazione trovata
	print("Classificazione non trovata né in POPM né nei TXXX")
	return -1


func get_duration(data: PackedByteArray) -> int:
	var duration_frame: PackedByteArray = read_frame(data, "TLEN")
	if duration_frame.size() > 0:
		print("Contenuto frame TLEN:", duration_frame)
		return int(duration_frame.get_string_from_ascii())
	print("Frame TLEN non presente")
	return -1

func get_cover(data: PackedByteArray) -> Dictionary:
	var header := read_id3v2_header(data)
	if !header.valid:
		return {}
		
	var covers: Array[Dictionary] = []
	var pos: int = 10  # Dopo l'header ID3
	
	while pos < header.size + 10:  # +10 per includere la dimensione dell'header
		if pos + 10 > data.size():
			break
			
		var frame_header := data.slice(pos, pos + 10)
		var frame_id := frame_header.slice(0, 4).get_string_from_ascii()
		var frame_size := unsynchsafe(frame_header.slice(4, 8))
		var frame_flags := (frame_header[8] << 8) | frame_header[9]
		
		pos += 10
		
		if frame_id == "APIC":
			if pos + frame_size > data.size():
				print("Frame APIC troncato")
				break
				
			var frame_data := data.slice(pos, pos + frame_size)
			var cover := parse_apic_frame(frame_data, header.version)
			if !cover.is_empty():
				covers.append(cover)
		
		pos += frame_size
	
	# Scegliamo la cover migliore disponibile
	return select_best_cover(covers)

func parse_apic_frame(frame_data: PackedByteArray, id3_version: int) -> Dictionary:
	var result := {
		"mime_type": "",
		"picture_type": 0,
		"description": "",
		"image_data": PackedByteArray()
	}
	
	if frame_data.is_empty():
		return {}
	
	var encoding := frame_data[0]
	var pos := 1
	
	# Cerca la fine del MIME type
	var mime_end := frame_data.find(0, pos)
	if mime_end != -1:
		result.mime_type = frame_data.slice(pos, mime_end).get_string_from_ascii()
		pos = mime_end + 1
		
		if pos < frame_data.size():
			result.picture_type = frame_data[pos]
			pos += 1
			
			# Salta la descrizione in base all'encoding
			match encoding:
				0:  # ASCII
					var desc_end := frame_data.find(0, pos)
					pos = desc_end + 1 if desc_end != -1 else pos
				1, 2:  # UTF-16
					while pos < frame_data.size() - 1:
						if frame_data[pos] == 0 and frame_data[pos + 1] == 0:
							pos += 2
							break
						pos += 1
				3:  # UTF-8
					var desc_end := frame_data.find(0, pos)
					pos = desc_end + 1 if desc_end != -1 else pos
	
	# Cerca l'inizio effettivo dei dati dell'immagine
	var image_start := pos
	while image_start < frame_data.size() - 2:
		# Cerca la signature JPEG
		if frame_data[image_start] == 0xFF and frame_data[image_start + 1] == 0xD8:
			result.mime_type = "image/jpeg"
			result.image_data = frame_data.slice(image_start)
			print("JPEG trovato alla posizione:", image_start)
			print("Dimensione dati immagine:", result.image_data.size())
			# Verifica che l'immagine termini correttamente con EOI marker
			var has_eoi := false
			for i: int in range(result.image_data.size() - 2):
				if result.image_data[i] == 0xFF and result.image_data[i + 1] == 0xD9:
					has_eoi = true
					# Taglia via eventuali dati extra dopo l'EOI
					result.image_data = result.image_data.slice(0, i + 2)
					break
			if !has_eoi:
				print("Warning: JPEG senza marker EOI valido")
			break
			
		# Cerca la signature PNG
		elif frame_data[image_start] == 0x89 and frame_data[image_start + 1] == 0x50:
			result.mime_type = "image/png"
			result.image_data = frame_data.slice(image_start)
			print("PNG trovato alla posizione:", image_start)
			break
			
		image_start += 1
	
	return result

func create_image_from_cover_data(cover_data: Dictionary) -> Image:
	if cover_data.is_empty() or cover_data.image_data.is_empty():
		print("Dati cover vuoti o mancanti")
		return null
		
	var image: Image = Image.new()
	var error: Error
	
	print("Tentativo di caricamento immagine di tipo:", cover_data.mime_type)
	print("Dimensione dati:", cover_data.image_data.size())
	print("Primi byte:", cover_data.image_data.slice(0, 4))
	
	# Verifica che i dati inizino con i marker corretti
	if cover_data.mime_type.begins_with("image/jp"):  # jpeg o jpg
		if cover_data.image_data.size() < 2 or cover_data.image_data[0] != 0xFF or cover_data.image_data[1] != 0xD8:
			print("Errore: Dati JPEG non validi - Header mancante")
			return null
			
		error = image.load_jpg_from_buffer(cover_data.image_data)
		if error != OK:
			print("Errore caricamento JPEG:", error)
			# Prova a salvare i dati per debug
			var file: FileAccess = FileAccess.open(OS.get_user_data_dir().path_join("debug_cover.jpg"), FileAccess.WRITE)
			if file:
				file.store_buffer(cover_data.image_data)
				print("Dati JPEG salvati in '" + OS.get_user_data_dir().path_join("debug_cover.jpg") + "' per debug")
			file.close()
			return null
			
	elif cover_data.mime_type == "image/png":
		if cover_data.image_data.size() < 8 or cover_data.image_data[0] != 0x89 or cover_data.image_data[1] != 0x50:
			print("Errore: Dati PNG non validi - Header mancante")
			return null
			
		error = image.load_png_from_buffer(cover_data.image_data)
		if error != OK:
			print("Errore caricamento PNG:", error)
			return null
	else:
		print("Tipo MIME non supportato:", cover_data.mime_type)
		return null
		
	if error == OK:
		print("Immagine caricata con successo")
		return image
	else:
		print("Errore generico nel caricamento dell'immagine:", error)
		return null

func select_best_cover(covers: Array[Dictionary]) -> Dictionary:
	if covers.is_empty():
		return {}
	
	# Priorità dei tipi di immagine (secondo lo standard ID3v2)
	var type_priority: Dictionary[int, int] = {
		3: 0,   # Cover frontale
		2: 1,   # File icon
		1: 2,   # Icon 32x32
		0: 3,   # Other
		4: 4,   # Cover posteriore
	}
	
	# Priorità dei formati immagine
	var mime_priority: Dictionary[String, int] = {
		"image/jpeg": 0,
		"image/jpg": 0,
		"image/png": 1,
		"image/gif": 2
	}
	
	var best_cover: Dictionary = covers[0]
	var best_priority: int = 999
	
	for cover: Dictionary[String, Variant] in covers:
		var type_prio: int = type_priority.get(cover.picture_type, 999)
		var mime_prio: int = mime_priority.get(cover.mime_type.to_lower(), 999)
		var current_priority: int = type_prio * 1000 + mime_prio
		#print("COVER: ", cover)
		if current_priority < best_priority:
			best_priority = current_priority
			best_cover = cover
		elif current_priority == best_priority and cover.image_data.size() > best_cover.image_data.size():
			# A parità di priorità, scegli l'immagine più grande
			best_cover = cover
	
	return best_cover

# Funzione generica per leggere i frame di testo
func read_text_frame(data: PackedByteArray, frame_id: String) -> String:
	var text_frame: PackedByteArray = read_frame(data, frame_id)
	if text_frame.size() > 0:
		# Il primo byte è l'encoding
		var encoding: int = text_frame[0]
		var text_data: PackedByteArray = text_frame.slice(1)
		
		match encoding:
			0:  # ISO-8859-1
				return text_data.get_string_from_ascii()
			1:  # UTF-16 con BOM
				# Rimuoviamo il BOM e decodifichiamo come UTF-16
				if text_data.size() >= 2:
					return text_data.slice(2).get_string_from_utf16()
			2:  # UTF-16BE
				return text_data.get_string_from_utf16()
			3:  # UTF-8
				return text_data.get_string_from_utf8()
		
		# Fallback a ASCII se l'encoding non è gestito
		return text_data.get_string_from_ascii()
	
	return ""

## Funzione per ottenere il [i]titolo[/i]
func get_title(data: PackedByteArray) -> String:
	var title := read_text_frame(data, "TIT2")
	if title.is_empty():
		print("Nessun titolo trovato")
		return ""
	
	print("Titolo trovato:", title)
	return title.strip_edges()

## Funzione per ottenere l'[i]artista[/i]
func get_artist(data: PackedByteArray) -> String:
	var artist := read_text_frame(data, "TPE1")
	if artist.is_empty():
		print("Nessun artista trovato")
		return ""
	
	print("Artista trovato:", artist)
	return artist.strip_edges()

## Funzione per ottenere l'[i]album[/i]
func get_album(data: PackedByteArray) -> String:
	var album := read_text_frame(data, "TALB")
	if album.is_empty():
		print("Nessun album trovato")
		return ""
	
	print("Album trovato:", album)
	return album.strip_edges()

## Funzione per ottenere l'[i]artista dell'album[/i]
func get_album_artist(data: PackedByteArray) -> String:
	var album_artist := read_text_frame(data, "TPE2")
	if album_artist.is_empty():
		print("Nessun artista dell'album trovato")
		return ""
	
	print("Artista dell'album trovato:", album_artist)
	return album_artist.strip_edges()

## Funzione per ottenere il [i]lyricist(paroliere)[/i]
func get_lyricist(data: PackedByteArray) -> String:
	var lyricist := read_text_frame(data, "TOLY")
	if lyricist.is_empty():
		print("Nessun lyricist trovato")
		return ""
	
	print("Lyricist trovato:", lyricist)
	return lyricist.strip_edges()

## Funzione per ottenere l'[i]anno[/i]
func get_year(data: PackedByteArray) -> int:
	var year: String = read_text_frame(data, "TYER")
	if year.is_empty():
		print("Nessun anno trovato")
		return -1
	
	print("Anno trovato:", year)
	return int(year.strip_edges())

## Funzione per ottenere la [i]data[/i]
func get_date(data: PackedByteArray) -> String:
	var date: String = read_text_frame(data, "TDRV")
	if date.is_empty():
		print("Nessun date trovato")
		return ""
	
	print("Date trovato:", date)
	return date.strip_edges()

## Funzione alternativa per ottenere la [i]data[/i]
func get_date_alt(data: PackedByteArray) -> String:
	var date_alt: String = read_text_frame(data, "TDRC")
	if date_alt.is_empty():
		print("Nessun date alt trovato")
		return ""
	
	print("Date Alt trovato:", date_alt)
	return date_alt.strip_edges()

## Funzione per ottenere il [i]release label[/i]
func get_release_label(data: PackedByteArray) -> String:
	var release_label: String = read_text_frame(data, "TPUB")
	if release_label.is_empty():
		print("Nessun release label trovato")
		return ""
	
	print("Release label trovato:", release_label)
	return release_label.strip_edges()

## Funzione per ottenere il [i]genere[/i]
func get_genre(data: PackedByteArray) -> String:
	var genre: String = read_text_frame(data, "TCON")
	if genre.is_empty():
		print("Nessun genere trovato")
		return ""
	
	print("Genere trovato:", genre)
	return genre.strip_edges()

## Funzione per ottenere il [i]copyright[/i]
func get_copyright(data: PackedByteArray) -> String:
	var copyright: String = read_text_frame(data, "TCOP")
	if copyright.is_empty():
		print("Nessun copyright trovato")
		return ""
	
	print("Copyright trovato:", copyright)
	return copyright.strip_edges()

## Funzione per ottenere l'[i]isrc[/i]
func get_isrc(data: PackedByteArray) -> String:
	var isrc: String = read_text_frame(data, "TSRC")
	if isrc.is_empty():
		print("Nessun isrc trovato")
		return ""
	
	print("ISRC trovato:", isrc)
	return isrc.strip_edges()

## Funzione per ottenere i [i]comments[/i]
func get_comments(data: PackedByteArray) -> String:
	var comments: String = read_text_frame(data, "COMM")
	if comments.is_empty():
		print("Nessun comments trovato")
		return ""
	
	print("Comments trovato:", comments)
	return comments.strip_edges()

## Funzione per ottenere metadati aggiunti dall'[i]user[/i]
func get_user(data: PackedByteArray) -> String:
	var user: String = read_text_frame(data, "TXXX")
	if user.is_empty():
		print("Nessun user trovato")
		return ""
	
	print("User trovato:", user)
	return user.strip_edges()

## Funzione per ottenere metadati aggiunti dall'[i]user[/i]
func get_mood(data: PackedByteArray) -> String:
	var mood: String = read_text_frame(data, "TMOO")
	if mood.is_empty():
		print("Nessun mood trovato")
		return ""
	
	print("Mood trovato:", mood)
	return mood.strip_edges()

#endregion

#region Metadata Writing Region

#endregion

func songElementPressed() -> void:
	if !main.smooth_scroll_container.velocity > Vector2.ZERO:
		songElementButton.grab_focus()
		songElementSelected.emit(self, songFileName, songFileNamePath, songFileNameDir, %Author.text, %SongTitle.text, %TotalDuration.text, currentSongTimestamp, songInfo)
		
		var tween: Tween = create_tween()
		
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		tween.set_trans(Tween.TRANS_QUAD)
		
		tween.parallel().tween_property(self, "modulate", Color.WHITE * 1.15, 0.2).from_current()

func _on_song_element_button_mouse_entered() -> void:
	hover = true
	
	var tween: Tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(self, "scale", Vector2(0.98, 0.98), .15).from_current()
	tween.parallel().tween_property(self, "modulate", Color.WHITE * 1.175, .15).from_current()
	#tween.chain().tween_property(songElementButton, "scale", Vector2(0.98, 0.98), .15)
	
	if !get_meta("mini", "bool"):
		%HoverPanel.show()


func _on_song_element_button_mouse_exited() -> void:
	hover = false
	
	var tween: Tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), .15).from_current()
	
	if playing:
		tween.parallel().tween_property(self, "modulate", Color.WHITE * 1.15, .2).from_current()
	else:
		tween.parallel().tween_property(self, "modulate", Color.WHITE, .15).from_current()
	
	#tween.chain().tween_property(songElementButton, "scale", Vector2(1.0, 1.0), .15)
	
	if !get_meta("mini", "bool"):
		%HoverPanel.hide()


func _on_song_element_button_pressed() -> void:
	pass


func _on_song_element_button_button_up() -> void:
	songElementPressed()
	var tween: Tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), .15)
	tween.chain().tween_property(songElementButton, "scale", Vector2(1.0, 1.0), .15)


func _on_song_element_button_button_down() -> void:
	var tween: Tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), .15)
	tween.chain().tween_property(songElementButton, "scale", Vector2(0.95, 0.95), .15)

func setTitle(title : String) -> void:
	%SongTitle.text = title

func setAuthor(Author : String) -> void:
	%Author.text = Author

func setProgressBarValue(value : float) -> void:
	%songProgressBar.value = value

func setCurrentDuration(currentDuration : String) -> void:
	%CurrentDuration.text = currentDuration

func setTotalDuration(totalDuration : String) -> void:
	%TotalDuration.text = totalDuration

func setSongFileName(songName : String) -> void:
	songFileName = songName

func setSongFileNamePath(songPath : String) -> void:
	songFileNamePath = songPath

func setSongFileNameDir(songDir : String) -> void:
	songFileNameDir = songDir

func songElementSelectedThumbnailOpacityOnAnimation() -> void:
	var tween : Tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(song_thumbnail_panel_container, "self_modulate", Color(0, 0, 0, 0.5), 0.35)

func songElementSelectedThumbnailOpacityOffAnimation() -> void:
	var tween : Tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(song_thumbnail_panel_container, "self_modulate", Color(0, 0, 0, 0), 0.35)

func playPlayingAnimation() -> void:
	#$Panel/Label.show()
	%linesAnimationPlayer.play("playing")
	songElementSelectedThumbnailOpacityOnAnimation()
	$Panel/MarginContainer/HBoxContainer/MarginContainer/PanelContainer/Panel/HBoxContainer.show()

func stopPlayingAnimation() -> void:
	#$Panel/Label.hide()
	%linesAnimationPlayer.play("RESET")
	songElementSelectedThumbnailOpacityOffAnimation()
	$Panel/MarginContainer/HBoxContainer/MarginContainer/PanelContainer/Panel/HBoxContainer.hide()


func _on_song_element_button_focus_entered() -> void:
	%HoverPanel.show()

func _on_song_element_button_focus_exited() -> void:
	%HoverPanel.hide()


func _on_resized() -> void:
	pivot_offset = size / 2.0
