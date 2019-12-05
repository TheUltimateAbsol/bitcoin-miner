extends Node

#enum Characters {NONE, BOY, GIRL}
#enum Transitions{NONE, FLASH, FADE, SLIDE_RIGHT, SLIDE_LEFT} #character
#enum Expressions{DEFAULT, HAPPY, SAD}
#enum Music{SAME, NONE, SIMPLE, SAD}
#enum Backgrounds{SAME, NONE, CLASSROOM}
#enum SoundEffect{NONE, DING, THWACK, WHACK} # when the text appears on the screen (sentence per sentence basis)

const Characters = {"NONE":"NONE", "BOY":"BOY", "GIRL":"GIRL"} 
const Transitions = {"NONE":"NONE", "FLASH":"FLASH", "FADE":"FADE", "SLIDE_RIGHT":"SLIDE_RIGHT", "SLIDE_LEFT":"SLIDE_LEFT"} #character
const Expressions = {"DEFAULT":"DEFAULT", "HAPPY":"HAPPY", "SAD":"SAD"}
const Music = {"SAME":"SAME", "NONE":"NONE", "SIMPLE":"SIMPLE", "SAD":"SAD"}
const Backgrounds = {"SAME":"SAME", "NONE":"NONE", "CLASSROOM":"CLASSROOM"}
const Background_transitiosn = {"NONE":"NONE", "FADE":"FADE", "BLACK":"BLACK"}
# when the text appears on the screen (sentence per sentence basis)
const SoundEffect = {"NONE":"NONE", "DING":"DING", "THWACK":"THWACK", "WHACK":"WHACK"}