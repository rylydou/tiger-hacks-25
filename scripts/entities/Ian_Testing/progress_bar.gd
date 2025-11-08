extends ProgressBar


func _on_processor_processing_progress_changed(progress: float) -> void:
	value = progress * 100.0


func _on_processor_processing_completed() -> void:
	value = 0
