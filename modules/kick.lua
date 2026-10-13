local S = _G.KZ
if not S then return end
if S.NewHook then
    S.NewHook(function(self, method, OLD, ...)
        if method == "Kick" and self == S.LP then return nil end
        return OLD(self, ...)
    end)
end
print("[KZ] anti kick loaded!!")
