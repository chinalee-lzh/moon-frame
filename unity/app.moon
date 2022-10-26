csapp = include('unity.interface').Application

local isEditor, dataPath, persistentDataPath, streamingAssetsPath, frameRate
{
  isEditor: ->
    isEditor = ENSURE.boolean(isEditor, csapp.isEditor)
    isEditor
  dataPath: ->
    dataPath = ENSURE.string(dataPath, csapp.dataPath)
    dataPath
  persistentDataPath: ->
    persistentDataPath = ENSURE.string(persistentDataPath, csapp.persistentDataPath)
    persistentDataPath
  streamingAssetsPath: ->
    streamingAssetsPath = ENSURE.string(streamingAssetsPath, csapp.streamingAssetsPath)
    streamingAssetsPath
  getFPS: ->
    frameRate = ENSURE.number(streamingAssetsPath, csapp.targetFrameRate)
    frameRate
  setFPS: (fps) ->
    return unless isnumber(fps)
    frameRate = fps
    csapp.targetFrameRate = fps
}