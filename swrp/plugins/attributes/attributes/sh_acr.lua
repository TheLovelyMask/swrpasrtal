ATTRIBUTE.name = "Акробатика"
ATTRIBUTE.description = "Влияет на то, как высоко вы можете прыгать."

function ATTRIBUTE:OnSetup(client, value)
	client:SetJumpPower(200 + value / 2)
end
