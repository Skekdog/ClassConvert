local function Levenshtein(a: string, b: string): number
	local len1, len2 = #a, #b
	local matrix = {}

	for i = 0, len1 do
		matrix[i] = {[0] = i}
	end
	for j = 1, len2 do
		matrix[0][j] = j
	end

	for i = 1, len1 do
		for j = 1, len2 do
			local cost = (a:sub(i, i) == b:sub(j, j)) and 0 or 1
			matrix[i][j] = math.min(matrix[i-1][j] + 1, matrix[i][j-1] + 1, matrix[i-1][j-1] + cost)
		end
	end
	
	return matrix[len1][len2]
end

return Levenshtein