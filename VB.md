VB 6 Learning Notes
===================

Just a personal note. For the Algorithm lesson I have to use VB6. 

beep
---

``` VB
Public Declare Function SysBeep & Lib "kernel32" Alias "Beep" (ByVal Freq As Long, ByVal Duration As Long)'Declare the Beep

Dim freq As Integer 'Hz 37 to 32,767
Dim length As Integar 'ms

SysBeep freq, length 'Just telling myself how to use this……Don't be serious.
```

`Beep（）` Also works but it plays the "Default Beep" sound from the user's Windows sound scheme. NOT SUPPORTED FOR WINDOWS VISTA

