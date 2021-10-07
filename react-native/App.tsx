import {createBottomTabNavigator} from '@react-navigation/bottom-tabs';
import {NavigationContainer} from '@react-navigation/native';
import * as React from 'react';
import CreativeKitScreen from './CreativeKitScreen';

const Tab = createBottomTabNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Tab.Navigator>
        <Tab.Screen name="CreativeKitScreen" component={CreativeKitScreen} />
      </Tab.Navigator>
    </NavigationContainer>
  );
}
