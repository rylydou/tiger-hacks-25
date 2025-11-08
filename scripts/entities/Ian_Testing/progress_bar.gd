extends ProgressBar


func _on_processor_processing_progress_changed(progress: float) -> void:
	value = progress * 100.0
