import {Navigator} from './Navigator'
import React, {useEffect} from 'react'
import {AppRegistry} from 'react-native'
import store from './store'
import {router} from './router'
import {
  NavigationBridge,
  EventEmitter,
  NAVIGATION_EVENT,
  COMPONENT_RESULT,
  SCREEN_ID,
  RESULT_TYPE,
  EVENT_TYPE,
  RESULT_DATA,
  RESULT_TYPE_CANCEL,
} from './NavigationModule'

export interface NavigationProps {
  navigator: Navigator
  screenID: string
}

interface Props {
  screenID: string
}

const withNavigator = (moduleName: string) => {
  return (WrappedComponent: React.ComponentType<any>) => {
    const FC = (props: Props, ref: React.Ref<React.ComponentType<any>>) => {
      const {screenID} = props
      const navigator = store.getNavigator(screenID) || new Navigator(screenID, moduleName)
      store.addNavigator(screenID, navigator)
      useEffect(() => {
        const subscription = EventEmitter.addListener(NAVIGATION_EVENT, data => {
          if (data[SCREEN_ID] === screenID && data[EVENT_TYPE] === COMPONENT_RESULT) {
            if (data[RESULT_TYPE] === RESULT_TYPE_CANCEL) {
              navigator.cancel()
            } else {
              navigator.excute(data[RESULT_DATA])
            }
          }
        })
        return () => {
          store.deleteNavigator(navigator.screenID)
          subscription.remove()
        }
      }, [])
      const injected = {
        navigator,
      }
      return <WrappedComponent ref={ref} {...props} {...injected} />
    }
    const FREC = React.forwardRef(FC)
    return FREC
  }
}

export const beforeRegister = () => {
  store.clearNavigator()
  router.clear()
}

export const registerComponent = (appKey: string, component: any, routeConfig?: string) => {
  if (routeConfig) {
    router.addRouteConfig(appKey, routeConfig)
  }
  const options = component.navigationItem || {}
  NavigationBridge.registerReactComponent(appKey, options)
  const withComponent = withNavigator(appKey)(component)
  AppRegistry.registerComponent(appKey, () => withComponent)
}

export const setRoot = (tree: {[key: string]: string}) => {
  NavigationBridge.setRoot(tree)
}
