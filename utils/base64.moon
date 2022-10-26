b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
{
  encode: (data) ->
    (data\gsub('.', (x) ->
      r, b = '', x\byte!
      for i = 8, 1 -1 do r ..=(b%2^i-b%2^(i-1)) > 0 and '1' or '0'
      r
    ) .. '0000')\gsub('%d%d%d?%d?%d?%d?', (x) ->
      return '' if #x < 6
      c = 0
      for i = 1, 6 do c += x\sub(i, i) == '1' and 2^(6-i) or 0
      b\sub(c+1, c+1)
    ) .. ({'', '==', '='})[#data%3+1]
  decode: (data) ->
    data = data\gsub('[^' .. b .. '=', '')
    (data\gsub('.', (x) ->
      return '' if x == '='
      r, f = '', b\find(x)-1
      for i = 6, 1, -1 do r ..= (f%2^i-f%2^(i-1)) > 0 and '1' or '0'
      r
    )\gsub('%d%d%d?%d?%d?%d?%d?%d?', (x) ->
      return '' unless #x == 8
      c = 0
      for i = 1, 8 do c += x\sub(i, i) == '1' and 2^(8-i) or 0
      string.char(c)
    ))
}