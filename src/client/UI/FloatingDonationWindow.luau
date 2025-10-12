local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MarketplaceService = game:GetService("MarketplaceService")

local Packages = ReplicatedStorage.Packages

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local Lydie = require(Packages.Lydie)
local Fusion = require(Packages.Fusion)

local Components = Lydie.Components
local Modules = Lydie.Modules

local Icons = Modules.Icons

local FloatingDonationWindow = {}

local windowVisibility = Fusion.Value(false)

function FloatingDonationWindow:Main()
	self:Create()
end

function FloatingDonationWindow:GenerateProductList()
	local pages = MarketplaceService:GetDeveloperProductsAsync()
	local developerProducts = pages:GetCurrentPage()

	local productsUI = {}
	-- loop developer product
	for _, product in ipairs(developerProducts) do
		print(product)
		local defaultIconId = "rbxassetid://6034177727" -- ID for a default placeholder icon
		local iconImageId = product.IconImageAssetId or defaultIconId
		local valueText = Fusion.Value(product.Name)
		table.insert(
			productsUI,
			Fusion.New("Frame")({
				Name = "item:" .. tostring(product.ProductId),
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(0, 50),
				Size = UDim2.new(1, 0, 0, 50),
				[Fusion.Children] = {
					Fusion.New("ImageLabel")({
						Size = UDim2.new(0, 40, 0, 40),
						Position = UDim2.fromOffset(5, 5),
						Image = "rbxassetid://" .. tostring(iconImageId),
					}),
					Components.Controls.IconTextButton({
						Size = UDim2.fromOffset(260, 45),
						Position = UDim2.fromOffset(50, 0),
						Text = valueText,
						Icon = Icons.coins,
						OnClickDown = function() end,
						OnClick = function()
							local localPlayer = Players.LocalPlayer
							MarketplaceService:PromptProductPurchase(localPlayer, product.ProductId)
						end,
					}),
				},
			})
		)
	end
	return productsUI
end

function FloatingDonationWindow:Toggle()
	local value = windowVisibility:get()
	windowVisibility:set(not value)
end

function FloatingDonationWindow:Create()
	local productsUI = self:GenerateProductList()

	Fusion.New("ScreenGui")({
		Parent = PlayerGui,
		Name = "DonationWindowGUI",
		[Fusion.Children] = {
			Components.Views.Window({
				Position = UDim2.new(0.5, 0, 0.5, -45),
				AspectRatio = Fusion.Value(0.65),
				Visible = windowVisibility,
				ZIndex = 10,
				[Fusion.Children] = {
					Components.Views.TopAppBar({
						Name = "TopBar",
						Icon = Icons.coins,
						Title = Fusion.Value("Support US"),
						-- Subtitle = Fusion.Value("Dukung kami untuk tetap bisa berkarya !"),
						ZIndex = 2,
						BackgroundColor = Modules.Scheme.GetAnimated(Modules.Scheme.Accent),
						BackgroundColor3 = Modules.Scheme.GetAnimated(Modules.Scheme.Accent),
						[Fusion.Children] = {
							Components.Controls.AppBarButton({
								Icon = Icons.x,

								OnClick = function()
									windowVisibility:set(false)
								end,
							}),
						},
					}),
					Fusion.New("Frame")({
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 1, 0),
						[Fusion.Children] = {
							Fusion.New("UIListLayout")({
								FillDirection = Enum.FillDirection.Vertical,
								Padding = UDim.new(0, 0),
								SortOrder = Enum.SortOrder.LayoutOrder,
								VerticalAlignment = Enum.VerticalAlignment.Center,
							}),
							Fusion.New("Frame")({
								Name = "item:padding",
								BackgroundTransparency = 1,
								Position = UDim2.fromOffset(0, 50),
								Size = UDim2.new(1, 0, 0, 50),
							}),
							unpack(productsUI),
						},
					}),
				},
			}),
		},
	})
end
return FloatingDonationWindow
