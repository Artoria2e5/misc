# VB6 基本参考
<small><i>本文针对 Visual Basic 98, 内容仅供参考。</i></small>

## Hello world
VB 存在多种 Hello world, 反正就是没 CLI 版本的。*这是我瞎说*

以下的 `Hello, world` 使用 `Label.Caption`:
```VB
Private Sub Form_Load() '当加载时
  Label1.Caption = "Hello, world!"
End Sub
```

## 数据类型
基本上 `Cbalabala()` 就是转换为 `balabala` 类型。
<table>
  <tr>
    <th>Name</th><th>Description</th>
  </tr>
  <tr><td>Numeric</td><td>Integer(N): -32768~32767, 2 Bytes; <br />Long(L): -2147483648~2147483647, 4 Bytes;</td></tr>
  <tr><td>Single(F): 32-bit float; Double:(D) 64-bit double-float; Currency(C):</td></tr>
  <tr><td>Byte</td><td>0~255(0x00~0xFF), 1 Byte.</td></tr>
  <tr><td>String(S)</td><td>Char String, One Byte per Character.<br />Length.Max=65536 for Fixed Length;<br /> 0~231 for variable length.</td></tr>
  <tr><td>Boolean(B)</td><td>True or False.</td></tr>
  <tr><td>Date</td><td>Windows: 1/1/1980～12/31/2099;<br />Visual Basic: 1/1/100～1/1/9999;<br />64-bit double.</td></tr>
  <tr><td>Object(O)</td><td>...</td></tr>
  <tr><td>Variant(V)</td><td>Changes its type when needed.</td></tr>
  </tr>
</table>

## 变量声明
变量名称必须以字母开头，不得包含保留字、句话和空格，名称长度不得超过 255. 
```VB
' 程序运行时 Static 变量保存临时数据。一旦程序终止，变量将自动被Visual Basic删除。下一次程序运行时该变量将重新被初始化。
' 但是，应用程序在运行时也有可能需要保留变量数据。Visual Basic可以通过声明静态变量来保存记忆变量数值。
Dim foo As N , ssy As L'过程变量, Or Static foo
Private bar As String, wkd As S'Private 类，你需要同一个 Class.
Public liGaBa As float 'Public 类，哪里都可以啪。
```
除此之外，还存在坑爹的隐式声明：
```VB
ljb%=3 ' % for Integer
cyf&=44 ' & for Long
wmy!=53 ' ! for Single (Uh-oh)
cyz#=12377.7 ' # for Double
xzm@=123.44453 ' @ for Currency
fsck$="So, Nvidia, fsck you!" ' $ for String
```
别忘了定长字符串：
```VB
'Visual Basic中也可以声明定义定长字符串。该字符串大小长度是固定不变的。如果该变量被赋予短于该长度的表达式，变量的剩余长度将以空格填充。如果长于该长度，自动截取等于该长度的字符，其余部分将被截去。
Dim varName as string * strlength
```

## 总算到了语句环节
### If
```VB
If condition Then
  [Statements]
[ElseIf condition2 Then]
  [ElIfStatements]
' Lots of ElseIf...
[Else]
  [ElseStatements]
End If
```
### Select Case
```VB
Select Case testExpression
     [Case Expressionlist1
            [statementblock-1]]
     [Case Expressionlist2
           [statementblock-2]]
     …..
    [Case Else]
           [statementblock-n]]
End Select
```
### For
```VB
For Student = 0 To 53 [Step step]
     [statements]
     [Exit For] ' 快逃啊！
     [statements]
Next [student]
```
### Do{While|Until}
```VB
Do {While|Until} PapapaIsAGirl()
  Fsck(Papapa)
  If Status.papapa=dead Then
    Exit Do
  End Of
  Fsck(Papapa, harder)
Loop
```
### For Each
```VB
For Each boy In class6_boys
  WearADress(boy)
Next [boy]
```


