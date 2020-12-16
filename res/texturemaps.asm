void        dw 64, 64, 64, 64, 64, 64, 64, 64
    .height dw 32
    .width  dw 32
    .seg    dw 0
    .addr   dw 0

digits      dw 0, 0, 8, 0, 16, 0, 24, 0, 32, 0, 40, 0, 48, 0, 56, 0, 64, 0, 72, 0
    .height dw 8
    .width  dw 8
    .seg    dw 0
    .addr   dw 0

high_score_label dw 0, 8
    .height dw 8
    .width  dw 80
    .seg    dw 0
    .addr   dw 0

game_over_label dw 0, 16
    .height dw 8
    .width  dw 72
    .seg    dw 0
    .addr   dw 0

ready_label dw 0, 24
    .height dw 8
    .width  dw 48
    .seg    dw 0
    .addr   dw 0

player_label dw 48, 24
    .height dw 8
    .width  dw 16
    .seg    dw 0
    .addr   dw 0

ghost_points dw 0, 48, 24, 48, 48, 48, 72, 48
    .height dw 8
    .width  dw 24
    .seg    dw 0
    .addr   dw 0

fruit_points dw 0, 40, 24, 40, 48, 40, 72, 40, 0, 32, 24, 32, 48, 32, 72, 32
    .height dw 8
    .width  dw 24
    .seg    dw 0
    .addr   dw 0

background  dw 96, 0
    .height dw 248
    .width  dw 224
    .seg    dw 0
    .addr   dw 0

small_pellet dw 64, 56
    .height dw 8
    .width  dw 8
    .seg    dw 0
    .addr   dw 0

large_pellet dw 72, 56
    .height dw 8
    .width  dw 8
    .seg    dw 0
    .addr   dw 0

exit        dw 200, 145
    .height dw 2
    .width  dw 16
    .seg    dw 0 
    .addr   dw 0 

pacman_go_up dw 64, 168, 80, 184, 64, 184, 80, 184
    .height dw 16
    .width  dw 16
    .seg    dw 0
    .addr   dw 0

pacman_go_down dw 64, 168, 80, 199, 64, 199, 80, 199
    .height dw 16
    .width  dw 16
    .seg    dw 0
    .addr   dw 0

pacman_go_right dw 64, 168, 80, 216, 64, 216, 80, 216
    .height dw 16
    .width  dw 16
    .seg    dw 0
    .addr   dw 0

pacman_go_left dw 64, 168, 80, 232, 64, 232, 80, 232
    .height dw 16
    .width  dw 16
    .seg    dw 0
    .addr   dw 0

pacman_death dw 64, 168, 80, 168, 64, 152, 80, 152, 64, 136, 80, 136, 64, 120, 80, 120, 64, 104, 80, 104, 64, 80, 80, 80
    .height dw 16
    .width  dw 16
    .seg    dw 0
    .addr   dw 0

red_ghost_go_up dw 48, 216, 48, 232, 48, 232, 48, 216
    .height dw 16
    .width  dw 16
    .seg    dw 0
    .addr   dw 0

red_ghost_go_down dw 32, 216, 32, 232, 32, 232, 32, 216 
    .height dw 16
    .width  dw 16
    .seg    dw 0
    .addr   dw 0

red_ghost_go_right dw 16, 216, 16, 232, 16, 232, 16, 216 
    .height dw 16
    .width  dw 16
    .seg    dw 0
    .addr   dw 0

red_ghost_go_left dw 0, 216, 0, 232, 0, 232, 0, 216 
    .height dw 16
    .width  dw 16
    .seg    dw 0
    .addr   dw 0

pink_ghost_go_up dw 48, 184, 48, 200, 48, 200, 48, 184
    .height dw 16
    .width  dw 16
    .seg    dw 0
    .addr   dw 0

pink_ghost_go_down dw 32, 184, 32, 200, 32, 200, 32, 184 
    .height dw 16
    .width  dw 16
    .seg    dw 0
    .addr   dw 0

pink_ghost_go_right dw 16, 184, 16, 200, 16, 200, 16, 184 
    .height dw 16
    .width  dw 16
    .seg    dw 0
    .addr   dw 0

pink_ghost_go_left dw 0, 184, 0, 200, 0, 200, 0, 184 
    .height dw 16
    .width  dw 16
    .seg    dw 0
    .addr   dw 0

cyan_ghost_go_up dw 48, 152, 48, 168, 48, 168, 48, 152
    .height dw 16
    .width  dw 16
    .seg    dw 0
    .addr   dw 0

cyan_ghost_go_down dw 32, 152, 32, 168, 32, 168, 32, 152 
    .height dw 16
    .width  dw 16
    .seg    dw 0
    .addr   dw 0

cyan_ghost_go_right dw 16, 152, 16, 168, 16, 168, 16, 152 
    .height dw 16
    .width  dw 16
    .seg    dw 0
    .addr   dw 0

cyan_ghost_go_left dw 0, 152, 0, 168, 0, 168, 0, 152 
    .height dw 16
    .width  dw 16
    .seg    dw 0
    .addr   dw 0

yellow_ghost_go_up dw 48, 120, 48, 136, 48, 136, 48, 120
    .height dw 16
    .width  dw 16
    .seg    dw 0
    .addr   dw 0

yellow_ghost_go_down dw 32, 120, 32, 136, 32, 136, 32, 120 
    .height dw 16
    .width  dw 16
    .seg    dw 0
    .addr   dw 0

yellow_ghost_go_right dw 16, 120, 16, 136, 16, 136, 16, 120 
    .height dw 16
    .width  dw 16
    .seg    dw 0
    .addr   dw 0

yellow_ghost_go_left dw 0, 120, 0, 136, 0, 136, 0, 120 
    .height dw 16
    .width  dw 16
    .seg    dw 0
    .addr   dw 0

scared_ghost dw 0, 104, 0, 104, 16, 104, 16, 104 
    .height dw 16
    .width  dw 16
    .seg    dw 0
    .addr   dw 0

scared_ghost_2 dw 32, 104, 32, 104, 48, 104, 48, 104 
    .height dw 16
    .width  dw 16
    .seg    dw 0
    .addr   dw 0

dead_ghost dw 48, 88, 16, 88, 32, 88, 0, 88 
    .height dw 16
    .width  dw 16
    .seg    dw 0
    .addr   dw 0
