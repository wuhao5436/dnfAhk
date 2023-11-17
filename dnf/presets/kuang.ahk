; ==================== 说明开始 ====================

; 这个脚本提供两个功能
; 1. 按下 z 的时候, 释放预先定义的小技能中的两个, 以达到快速叠C的功能 (会考虑冷却)
; 2. 使用输出技能的时候自动释放剑盾

; ==================== 说明结束 ====================

#NoEnv
#NoTrayIcon

SetWorkingDir ..

#Include lib\common_pre.ahk
#Include lib\autofire.ahk
#IfWinActive ahk_exe DNF.exe

; ==================== Customization Begin ====================

global smallSkills := [["血之狂暴", ["Down","Up", "Space"], 40], ["暴走", ["Left","Left", "Space"], 40],  ["嗜血", ["Up","Down", "Space"], 40], ["翔跃", ["Up", "Space"], 40], ["不屈意志", ["Down","Down", "Space"], 40],  ["卡赞", ["Left", "Space"], 40]]
; 用来叠 C 的小技能


global smallSkills2 := [["暴走", ["Left","Left", "Space"], 40],  ["嗜血", ["Up","Down", "Space"], 40], ["翔跃", ["Up", "Space"], 40], ["不屈意志", ["Down","Down", "Space"], 40],  ["卡赞", ["Left", "Space"], 40]]
; 用来叠 C 的小技能

global showSkills := True
; 是否在释放小技能叠 C 后显示放出的技能, 通常用于 debug

global smallSkillsDelay := [800, 800, 800, 800, 800, 300]
global smallSkillsDelay2 := [800, 800, 800, 800, 300]
; 小技能叠C后的延迟 (另外数组的长度即小技能的释放个数)

global keyXiaoXi := "d"
; 小吸按键

global skillDelay := {"s": 1000, "f": 1000 }
; 例如我 s 键是崩山击, 希望在该技能释放后 225ms 按小吸, 就设置 "a": 225
; 其他技能可以参考 https://bbs.colg.cn/thread-8027274-1-1.html, https://bbs.colg.cn/thread-7479247-1-1.html

; ==================== Customization End ====================

SetAutofire("x,a")

global keycodeXiaoXi := GetSpecialKeycode(keyXiaoXi)
global free := True

global smallSkillsLastFired := {}
for _, v in smallSkills {
    smallSkillsLastFired[v[1]] := 0
    v[3] := v[3] * 1000 + 50  ; 补正冷却时间 (s -> ms, 然后加上一点冗余量)
}


Hotkey, IfWinActive, ahk_exe 地下城与勇士.exe
for k, v in skillDelay {
    fn := Func("xiaoxiAfter").Bind(v)
    Hotkey, $~*%k%, %fn%
}
Hotkey, If

xiaoxiAfter(delay) {
    if (free) {
        free := False
        Sleep, delay
        ; RobustSend(keycodeXiaoXi)
    }
    free := True
}

; 进门
Numpad9::
    if (free) {
        free := False
        fireSmallSkills()
    }
    free := True
    return

fireSmallSkills() {
    ; 放两个小技能用于叠C
    fired := 0
    usedSkills := ""
    for _, skill in smallSkills {
        ToolTip1s(skill[1])
        ; if (A_TickCount - smallSkillsLastFired[skill[1]] > skill[3]) { 
            ; 该技能冷却已经转好了
            for _, key in skill[2] {
                RobustSend(GetSpecialKeycode(key))
            }
            smallSkillsLastFired[skill[1]] := A_TickCount
            Sleep, smallSkillsDelay[fired+1] - delay - duration
            ; 详细说明:
            ; AHK 中如果只是 Send {key} 经常会出现发不出去的情况
            ; 一个 workaround 是 Send {key down}; Sleep duration; Send {key up}; Sleep delay;
            ; 这部分具体实现见 common_pre.ahk
            ; 这导致技能实际是在 (now-delay-duration, now-delay) 这个区间就放出来了
            ; 相应的, 这里 Sleep 的时间也应该把这部分时间考虑进去, 满足从技能释放之后算起有 225ms 的间隔
            ; RobustSend(keycodeXiaoXi)
            fired += 1
            usedSkills .= skill[1] . " "
        ; }
        if (fired == smallSkillsDelay.MaxIndex()) {
            ; 放完了, 结束
            ;break
        }
    }
    if (showSkills) {
        Sleep, 2000
        ToolTip1s(usedSkills)
    }
}


; 中途
Numpad0::
    if (free) {
        free := False
        fireSmallSkills2()
    }
    free := True
    return

fireSmallSkills2() {
    ; 放两个小技能用于叠C
    fired := 0
    usedSkills := ""
    for _, skill in smallSkills2 {
        ToolTip1s(skill[1])
        ; if (A_TickCount - smallSkillsLastFired[skill[1]] > skill[3]) { 
            ; 该技能冷却已经转好了
            for _, key in skill[2] {
                RobustSend(GetSpecialKeycode(key))
            }
            smallSkillsLastFired[skill[1]] := A_TickCount
            Sleep, smallSkillsDelay2[fired+1] - delay - duration
            ; 详细说明:
            ; AHK 中如果只是 Send {key} 经常会出现发不出去的情况
            ; 一个 workaround 是 Send {key down}; Sleep duration; Send {key up}; Sleep delay;
            ; 这部分具体实现见 common_pre.ahk
            ; 这导致技能实际是在 (now-delay-duration, now-delay) 这个区间就放出来了
            ; 相应的, 这里 Sleep 的时间也应该把这部分时间考虑进去, 满足从技能释放之后算起有 225ms 的间隔
            ; RobustSend(keycodeXiaoXi)
            fired += 1
            usedSkills .= skill[1] . " "
        ; }
        if (fired == smallSkillsDelay2.MaxIndex()) {
            ; 放完了, 结束
            ;break
        }
    }
    if (showSkills) {
        Sleep, 2000
        ToolTip1s(usedSkills)
    }
}

#IfWinActive

#Include lib\common_post.ahk
