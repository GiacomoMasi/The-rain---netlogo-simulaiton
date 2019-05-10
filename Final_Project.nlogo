breed [humans human]
breed [infected-humans infected-human]
breed [immune-humans immune-humane]
breed [shelters shelter]
breed [trees tree]
breed [clouds cloud]
breed [stones stone]



globals [
  current-humans-number
  current-infected-humans-number
  die-threashold
  new-threashold
  create-one-human-flag
  random-patch
  tree-number
  stone-number
  rain-flag
  max-number-humans
  time
]



to setup ;setup function
  clear-all

  ask patches [set pcolor white]

  set current-humans-number number-of-humans
  set current-infected-humans-number number-of-infected-humans
  set die-threashold die-probability-infected-humans
  set new-threashold new-probability-humans
  set create-one-human-flag false
  set tree-number 100
  set stone-number 0
  set random-patch one-of turtles
  set rain-flag false
  set max-number-humans 150
  set time 0

  let index 0


  ask patches
  [
    set pcolor grey
  ]

  while [index < number-of-shelters]
  [

    create-shelters 1 [
      set color 36
      set shape "house"
      set xcor random-xcor
      set ycor random-ycor
      set size 3
    ]
    set index (index + 1)
  ]

  set index 0

  while [index < tree-number]
  [

    create-trees 1 [
      set color green
      set shape "tree"
      set xcor random-xcor
      set ycor random-ycor
      set size 1
    ]
    set index (index + 1)
  ]

  set index 0

  while [index < stone-number]
  [

    create-stones 1 [
      set color brown
      set shape "tile stones"
      set xcor random-xcor
      set ycor random-ycor
      set size 1
    ]
    set index (index + 1)
  ]

  create-humans number-of-humans [
    set color blue
    set shape "person"
    set xcor -10
    set ycor -10
  ]

  create-infected-humans number-of-infected-humans [
    set color black
    set shape "person"
    set xcor 0
    set ycor 0
  ]

  create-immune-humans number-of-immune-humans [
    set color red
    set shape "person"
    set xcor -9
    set ycor -9
  ]

  reset-ticks
end

to create-rain
  ifelse rain ; if the switch button is turn on, create clouds. Else ask clouds to die
  [

    if rain-flag = false [
      create-clouds rain-power [
        set shape "cloud"
        set xcor random-xcor
        set ycor random-ycor
        set color blue
        set size 4
      ]
      set rain-flag true
    ]

  ]
  [
    set rain-flag false
    ask clouds [
      die
    ]
  ]
end

to create-one-human ; create new human
  if ( (random-float 100) * 1.8 < (new-threashold / 2) )  [ ;check condition
    create-humans 1 [
      set current-humans-number ( current-humans-number + 1 )
      set color blue
      set shape "person"
      set xcor random-xcor
      set ycor random-ycor
    ]
  ]
end


to check-create-human-flag
  if create-one-human-flag = true [
    create-one-human
    set create-one-human-flag false
  ]
end

to immune-humans-behaviour
  let current-immune-human self

  if current-infected-humans-number > 0 [
    let closest-infected-human min-one-of other infected-humans [distance current-immune-human]
    if closest-infected-human != nobody [
      ask current-immune-human [
        face closest-infected-human ; check
      ]


      if distance closest-infected-human < 0.5 [
        if (random-float 100) * 1.8 < (safe-threashold / 2 ) [ ; check condition
          ask closest-infected-human [
            set breed humans
            set current-humans-number ( current-humans-number + 1 )
            set current-infected-humans-number ( current-infected-humans-number - 1)
            set color blue
            set shape "person"
          ]
        ]
      ]
    ]
  ]

end

to move-immune-humans ; immune human's move

  ask immune-humans [
    let dice random 3
    let change ( dice - 1 )
    forward 0.5
    set heading ( heading + change * 2 )

    if number-of-immune-humans > 0 [
      immune-humans-behaviour
    ]
  ]

end

to move-humans ; human's move

  ask humans [
    let dice random 3
    let change ( dice - 1 )
    forward 1
    set heading(heading + change * 10)

    if current-humans-number > 0 [
      human-behaviour
    ]
  ]

end


to human-behaviour

  let current-human self
  let closest-human min-one-of other humans [distance current-human]
  let closest-infected-human min-one-of other infected-humans [distance current-human]
  let closest-cloud min-one-of other clouds [distance current-human]
  let closest-shelter-tmp min-one-of other shelters [distance current-human]



  if current-humans-number >= 1 and current-infected-humans-number >= 1 [
    if ((closest-infected-human != nobody) and (closest-human != nobody)) [
      if current-infected-humans-number > 1 [
        ask current-human [
          face closest-infected-human
          right 180 ; turn right 180° -> move in the opposite direction
        ]
      ]
    ]
  ]

  if current-humans-number > 1 and current-humans-number < max-number-humans and distance closest-shelter-tmp > 3[
    if distance closest-human < 1 [
          set create-one-human-flag true
        ]
  ]

  if current-humans-number >= 1 and closest-cloud != nobody [

    let closest-shelter min-one-of other shelters [distance current-human]
    let distance-shelter-cloud [distance closest-shelter] of closest-cloud

    if distance closest-cloud < 2 and distance-shelter-cloud > 3 [
      ask current-human [
        set breed infected-humans
        set current-humans-number ( current-humans-number - 1 )
        set current-infected-humans-number ( current-infected-humans-number + 1)
        set color black
        set shape "person"
      ]
    ]
  ]

  ifelse rain
  [
    let closest-shelter min-one-of other shelters [distance current-human]
    ask current-human [
      face closest-shelter
    ]
  ]
  [ ;ask patches [ set pcolor white ]
  ]

end

to move-infected-humans


  ask infected-humans [
    let dice random 3
    let change ( dice - 1 )

    forward 1

    if current-humans-number > 0 [
      face one-of humans
    ]

    set heading(heading + change * 10)
    infected-human-behaviour
  ]

end

to infected-human-behaviour ; behaviour of infected humans

  let current-infected-human self
  let closest-human min-one-of other humans [distance current-infected-human]
  let closest-shelter min-one-of other shelters [distance current-infected-human]

  if distance closest-shelter < 3 [
    ask current-infected-human [
      right 180
    ]
  ]



  if current-humans-number > 0 [
    let closest-human-shelter min-one-of other shelters [distance closest-human]
    let distance-shelter-human [distance closest-human-shelter] of closest-human


    ifelse distance-shelter-human >= 3 [
      ask current-infected-human [
        face closest-human
      ]
      ask humans with [ distance current-infected-human < 1 ] [
        set current-humans-number ( current-humans-number - 1 )
        set current-infected-humans-number ( current-infected-humans-number + 1)
        set breed infected-humans
        set color black
        set shape "person"
      ]
    ]
    [
     ask current-infected-human [
        face one-of patches
      ]
    ]
  ]


  if ( (random-float 100) * 1.8) < (die-threashold / 2) [ ; check condition
    set current-infected-humans-number ( current-infected-humans-number - 1)
    die
  ]

end

to set-time
  tick
  tick
  set time (time + 1)
end

to simulation
  move-humans ; function which describes moves of humans
  move-infected-humans ; function which describes moves of infected humans
  move-immune-humans ; function which describes moves of immune humans
  check-create-human-flag ; function which checks if is the caso to create a new human or not
  create-rain ; switch button to regulates rain
  set-time ; function for updates the time in the UI
end
@#$#@#$#@
GRAPHICS-WINDOW
478
10
998
531
-1
-1
15.52
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

SLIDER
16
38
188
71
number-of-humans
number-of-humans
0
100
100.0
1
1
NIL
HORIZONTAL

BUTTON
17
364
80
397
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
18
413
81
446
clear
clear-all
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
15
84
219
117
number-of-infected-humans
number-of-infected-humans
0
100
0.0
1
1
NIL
HORIZONTAL

BUTTON
129
365
206
398
simulate
simulation
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
15
188
261
221
die-probability-infected-humans
die-probability-infected-humans
0
100
95.0
1
1
%
HORIZONTAL

SLIDER
16
243
214
276
new-probability-humans
new-probability-humans
0
100
30.0
1
1
%
HORIZONTAL

SLIDER
15
135
216
168
number-of-immune-humans
number-of-immune-humans
0
10
0.0
1
1
NIL
HORIZONTAL

SWITCH
129
407
232
440
rain
rain
1
1
-1000

SLIDER
264
35
436
68
number-of-shelters
number-of-shelters
0
5
5.0
1
1
NIL
HORIZONTAL

SLIDER
264
79
436
112
rain-power
rain-power
0
50
25.0
1
1
NIL
HORIZONTAL

SLIDER
16
289
188
322
safe-threashold
safe-threashold
0
100
10.0
1
1
%
HORIZONTAL

PLOT
1017
86
1305
315
Stat
Time
People
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"humans" 1.0 0 -14070903 true "" "plot current-humans-number"
"infected" 1.0 0 -16777216 true "" "plot current-infected-humans-number"
"immune" 1.0 0 -2674135 true "" "plot number-of-immune-humans"

MONITOR
1054
27
1119
72
Hours
time
1
1
11

MONITOR
1121
27
1185
72
Days
time / 24
1
1
11

MONITOR
1187
27
1251
72
Months
(time / 24 ) / 30
1
1
11

TEXTBOX
304
241
454
259
NIL
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cloud
false
0
Circle -7500403 true true 13 118 94
Circle -7500403 true true 86 101 127
Circle -7500403 true true 51 51 108
Circle -7500403 true true 118 43 95
Circle -7500403 true true 158 68 134

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tile stones
false
0
Polygon -7500403 true true 0 240 45 195 75 180 90 165 90 135 45 120 0 135
Polygon -7500403 true true 300 240 285 210 270 180 270 150 300 135 300 225
Polygon -7500403 true true 225 300 240 270 270 255 285 255 300 285 300 300
Polygon -7500403 true true 0 285 30 300 0 300
Polygon -7500403 true true 225 0 210 15 210 30 255 60 285 45 300 30 300 0
Polygon -7500403 true true 0 30 30 0 0 0
Polygon -7500403 true true 15 30 75 0 180 0 195 30 225 60 210 90 135 60 45 60
Polygon -7500403 true true 0 105 30 105 75 120 105 105 90 75 45 75 0 60
Polygon -7500403 true true 300 60 240 75 255 105 285 120 300 105
Polygon -7500403 true true 120 75 120 105 105 135 105 165 165 150 240 150 255 135 240 105 210 105 180 90 150 75
Polygon -7500403 true true 75 300 135 285 195 300
Polygon -7500403 true true 30 285 75 285 120 270 150 270 150 210 90 195 60 210 15 255
Polygon -7500403 true true 180 285 240 255 255 225 255 195 240 165 195 165 150 165 135 195 165 210 165 255

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
