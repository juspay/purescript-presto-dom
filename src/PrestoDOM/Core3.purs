module PrestoDOM.Core3 
  ( addChildImpl
  , addProperty
  , addScreenWithAnim
  , addToCachedList
  , addToPatchQueue
  , addViewToParent
  , attachScreen
  , awaitPrerenderFinished
  , cacheMachine
  , cachePushEvents
  , callAnimation
  , canPreRender
  , cancelBehavior
  , cancelExistingActions
  , checkAndDeleteFromHideAndRemoveStacks
  , controllerActions
  , createPrestoElement
  , createPushQueue
  , decrementPatchCounter
  , domAll
  , fireManualEvent
  , getAndSetEventFromState
  , getCachedMachine
  , getCachedMachineImpl
  , getCurrentActivity
  , getEventIO
  , getLatestMachine
  , getListDataCommands
  , getListDataFromMapps
  , getPaddingForStroke
  , getPushFn
  , hideCacheRootOnAnimationEnd
  , incrementPatchCounter
  , initUIWithNameSpace
  , initUIWithScreen
  , insertDom
  , isCached
  , isInStack
  , isScreenPushActive
  , joinCancellers
  , launchAffWithCounter
  , makeCacheRootVisible
  , makeScreenVisible
  , moveChild
  , parseParams
  , parseProps
  , patchAndRun
  , patchBlock
  , prepareAndStoreView
  , prepareDom
  , prepareScreen
  , processEvent
  , processEventWithId
  , removeChild
  , render
  , renderOrPatch
  , replaceView
  , replayFragmentCallbacks
  , replayFragmentCallbacks'
  , replayListFragmentCallbacks
  , runController
  , runScreen
  , sanitiseNamespace
  , saveCanceller
  , setControllerStates
  , setManualEvents
  , setPatchToActive
  , setScreenPushActive
  , setToTopOfStack
  , setUpBaseState
  , showScreen
  , spec
  , startedToPrepare
  , storeMachine
  , terminateUI
  , terminateUIImpl
  , terminateUIImplWithCallback
  , terminateUIWithCallback
  , updateChildren
  , updateChildrenImpl
  , updateMicroAppPayload
  , updateMicroAppPayloadImpl
  , updateProp
  , updateProperties
  , updatePropertiesImpl
  , updateScreen
  , updateActivity
  ) where

import PrestoDOM.Core2 as Core2
import PrestoDOM.Core4 as Core4

foreign import isPreRenderSupported :: Boolean

addChildImpl = if isPreRenderSupported then Core2.addChildImpl else Core4.addChildImpl
addProperty = if isPreRenderSupported then Core2.addProperty else Core4.addProperty
addScreenWithAnim = if isPreRenderSupported then Core2.addScreenWithAnim else Core4.addScreenWithAnim
addToCachedList = if isPreRenderSupported then Core2.addToCachedList else Core4.addToCachedList
addToPatchQueue = if isPreRenderSupported then Core2.addToPatchQueue else Core4.addToPatchQueue
addViewToParent = if isPreRenderSupported then Core2.addViewToParent else Core4.addViewToParent
attachScreen = if isPreRenderSupported then Core2.attachScreen else Core4.attachScreen
awaitPrerenderFinished = if isPreRenderSupported then Core2.awaitPrerenderFinished else Core4.awaitPrerenderFinished
cacheMachine = if isPreRenderSupported then Core2.cacheMachine else Core4.cacheMachine
cachePushEvents = if isPreRenderSupported then Core2.cachePushEvents else Core4.cachePushEvents
callAnimation = if isPreRenderSupported then Core2.callAnimation else Core4.callAnimation
canPreRender = if isPreRenderSupported then Core2.canPreRender else Core4.canPreRender
cancelBehavior = if isPreRenderSupported then Core2.cancelBehavior else Core4.cancelBehavior
cancelExistingActions = if false then Core2.cancelExistingActions else Core4.cancelExistingActions
checkAndDeleteFromHideAndRemoveStacks = if isPreRenderSupported then Core2.checkAndDeleteFromHideAndRemoveStacks else Core4.checkAndDeleteFromHideAndRemoveStacks
controllerActions = if isPreRenderSupported then Core2.controllerActions else Core4.controllerActions
createPrestoElement = if isPreRenderSupported then Core2.createPrestoElement else Core4.createPrestoElement
createPushQueue = if isPreRenderSupported then Core2.createPushQueue else Core4.createPushQueue
decrementPatchCounter = if isPreRenderSupported then Core2.decrementPatchCounter else Core4.decrementPatchCounter
domAll = if isPreRenderSupported then Core2.domAll else Core4.domAll
fireManualEvent = if isPreRenderSupported then Core2.fireManualEvent else Core4.fireManualEvent
getAndSetEventFromState = if isPreRenderSupported then Core2.getAndSetEventFromState else Core4.getAndSetEventFromState
getCachedMachine = if isPreRenderSupported then Core2.getCachedMachine else Core4.getCachedMachine
getCachedMachineImpl = if isPreRenderSupported then Core2.getCachedMachineImpl else Core4.getCachedMachineImpl
getCurrentActivity = if isPreRenderSupported then Core2.getCurrentActivity else Core4.getCurrentActivity
getEventIO = if isPreRenderSupported then Core2.getEventIO else Core4.getEventIO
getLatestMachine = if isPreRenderSupported then Core2.getLatestMachine else Core4.getLatestMachine
getListDataCommands = if isPreRenderSupported then Core2.getListDataCommands else Core4.getListDataCommands
getListDataFromMapps = if isPreRenderSupported then Core2.getListDataFromMapps else Core4.getListDataFromMapps
getPaddingForStroke = if isPreRenderSupported then Core2.getPaddingForStroke else Core4.getPaddingForStroke
getPushFn = if isPreRenderSupported then Core2.getPushFn else Core4.getPushFn
hideCacheRootOnAnimationEnd = if isPreRenderSupported then Core2.hideCacheRootOnAnimationEnd else Core4.hideCacheRootOnAnimationEnd
incrementPatchCounter = if isPreRenderSupported then Core2.incrementPatchCounter else Core4.incrementPatchCounter
initUIWithNameSpace = if isPreRenderSupported then Core2.initUIWithNameSpace else Core4.initUIWithNameSpace
initUIWithScreen = if isPreRenderSupported then Core2.initUIWithScreen else Core4.initUIWithScreen
insertDom = if isPreRenderSupported then Core2.insertDom else Core4.insertDom
isCached = if isPreRenderSupported then Core2.isCached else Core4.isCached
isInStack = if isPreRenderSupported then Core2.isInStack else Core4.isInStack
isScreenPushActive = if isPreRenderSupported then Core2.isScreenPushActive else Core4.isScreenPushActive
joinCancellers = if isPreRenderSupported then Core2.joinCancellers else Core4.joinCancellers
launchAffWithCounter = if isPreRenderSupported then Core2.launchAffWithCounter else Core4.launchAffWithCounter
makeCacheRootVisible = if isPreRenderSupported then Core2.makeCacheRootVisible else Core4.makeCacheRootVisible
makeScreenVisible = if isPreRenderSupported then Core2.makeScreenVisible else Core4.makeScreenVisible
moveChild = if isPreRenderSupported then Core2.moveChild else Core4.moveChild
parseParams = if isPreRenderSupported then Core2.parseParams else Core4.parseParams
parseProps = if isPreRenderSupported then Core2.parseProps else Core4.parseProps
patchAndRun = if isPreRenderSupported then Core2.patchAndRun else Core4.patchAndRun
patchBlock = if isPreRenderSupported then Core2.patchBlock else Core4.patchBlock
prepareAndStoreView = if isPreRenderSupported then Core2.prepareAndStoreView else Core4.prepareAndStoreView
prepareDom = if isPreRenderSupported then Core2.prepareDom else Core4.prepareDom
prepareScreen = if isPreRenderSupported then Core2.prepareScreen else Core4.prepareScreen
processEvent = if isPreRenderSupported then Core2.processEvent else Core4.processEvent
processEventWithId = if isPreRenderSupported then Core2.processEventWithId else Core4.processEventWithId
removeChild = if isPreRenderSupported then Core2.removeChild else Core4.removeChild
render = if isPreRenderSupported then Core2.render else Core4.render
renderOrPatch = if isPreRenderSupported then Core2.renderOrPatch else Core4.renderOrPatch
replaceView = if isPreRenderSupported then Core2.replaceView else Core4.replaceView
replayFragmentCallbacks = if isPreRenderSupported then Core2.replayFragmentCallbacks else Core4.replayFragmentCallbacks
replayFragmentCallbacks' = if isPreRenderSupported then Core2.replayFragmentCallbacks' else Core4.replayFragmentCallbacks'
replayListFragmentCallbacks = if isPreRenderSupported then Core2.replayListFragmentCallbacks else Core4.replayListFragmentCallbacks
runController = if isPreRenderSupported then Core2.runController else Core4.runController
runScreen = if isPreRenderSupported then Core2.runScreen else Core4.runScreen
sanitiseNamespace = if isPreRenderSupported then Core2.sanitiseNamespace else Core4.sanitiseNamespace
saveCanceller = if isPreRenderSupported then Core2.saveCanceller else Core4.saveCanceller
setControllerStates = if isPreRenderSupported then Core2.setControllerStates else Core4.setControllerStates
setManualEvents = if isPreRenderSupported then Core2.setManualEvents else Core4.setManualEvents
setPatchToActive = if isPreRenderSupported then Core2.setPatchToActive else Core4.setPatchToActive
setScreenPushActive = if isPreRenderSupported then Core2.setScreenPushActive else Core4.setScreenPushActive
setToTopOfStack = if isPreRenderSupported then Core2.setToTopOfStack else Core4.setToTopOfStack
setUpBaseState = if isPreRenderSupported then Core2.setUpBaseState else Core4.setUpBaseState
showScreen = if isPreRenderSupported then Core2.showScreen else Core4.showScreen
spec = if isPreRenderSupported then Core2.spec else Core4.spec
startedToPrepare = if isPreRenderSupported then Core2.startedToPrepare else Core4.startedToPrepare
storeMachine = if isPreRenderSupported then Core2.storeMachine else Core4.storeMachine
terminateUI = if isPreRenderSupported then Core2.terminateUI else Core4.terminateUI
terminateUIImpl = if isPreRenderSupported then Core2.terminateUIImpl else Core4.terminateUIImpl
terminateUIImplWithCallback = if isPreRenderSupported then Core2.terminateUIImplWithCallback else Core4.terminateUIImplWithCallback
terminateUIWithCallback = if isPreRenderSupported then Core2.terminateUIWithCallback else Core4.terminateUIWithCallback
updateChildren = if isPreRenderSupported then Core2.updateChildren else Core4.updateChildren
updateChildrenImpl = if isPreRenderSupported then Core2.updateChildrenImpl else Core4.updateChildrenImpl
updateMicroAppPayload = if isPreRenderSupported then Core2.updateMicroAppPayload else Core4.updateMicroAppPayload
updateMicroAppPayloadImpl = if isPreRenderSupported then Core2.updateMicroAppPayloadImpl else Core4.updateMicroAppPayloadImpl
updateProp = if isPreRenderSupported then Core2.updateProp else Core4.updateProp
updateProperties = if isPreRenderSupported then Core2.updateProperties else Core4.updateProperties
updatePropertiesImpl = if isPreRenderSupported then Core2.updatePropertiesImpl else Core4.updatePropertiesImpl
updateScreen = if isPreRenderSupported then Core2.updateScreen else Core4.updateScreen
updateActivity = if isPreRenderSupported then Core2.updateActivity else Core4.updateActivity


