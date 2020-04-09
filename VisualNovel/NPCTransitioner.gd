extends AnimationPlayer

func queue_out_in(closing_anim, opening_anim, texture, closing_backwards = false, opening_backwards=false):
		if closing_backwards:
			play_backwards(closing_anim)
		else:
			play(closing_anim)
		
		yield(self, "animation_finished");
		
		get_parent().texture = texture;
		
		if opening_backwards:
			play_backwards(opening_anim)
		else:
			play(opening_anim)
