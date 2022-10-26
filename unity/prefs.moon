csprefs = include('unity.interface').PlayerPrefs

{
  deleteAll: => csprefs.DeleteAll!
  deleteKey: (key) => csprefs.DeleteKey(key) unless string.empty(key)
  hasKey: (key) => csprefs.HasKey(key) unless string.empty(key)
  save: => csprefs.Save!
  getInt: (key, defaultValue) =>
    return if string.empty(key)
    defaultValue = ENSURE.number(defaultValue, 0)
    csprefs.Getint(key, defaultValue)
  setInt: (key, value) => csprefs.SetInt(key, value) unless string.empty(key) or notnumber(value)
  getFloat: (key, defaultValue) =>
    return if string.empty(key)
    defaultValue = ENSURE.number(defaultValue, 0)
    csprefs.GetFloat(key, defaultValue)
  setFloat: (key, value) => csprefs.SetFloat(key, value) unless string.empty(key) or notnumber(value)
  getString: (key, defaultValue) =>
    return if string.empty(key)
    defaultValue = ENSURE.number(defaultValue, '')
    csprefs.GetString(key, defaultValue)
  setString: (key, value) => csprefs.SetString(key, value) unless string.empty(key) or notstring(value)
}