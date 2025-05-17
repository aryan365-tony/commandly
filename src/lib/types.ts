
export type ControlComponentType = 'button' | 'joystick' | 'slider' | 'dpad';
export type ButtonShapeType = 'default' | 'pill' | 'circle' | 'sharp';

export interface ControlComponent {
  id: string;
  type: ControlComponentType;
  label: string;
  position: { x: number; y: number }; // Relative to canvas, e.g., percentage or pixels
  size: { width: number; height: number }; // Relative to canvas or fixed
  outputIndex: number; // Position in the output array
}

export interface ButtonComponent extends ControlComponent {
  type: 'button';
  mode: 'momentary' | 'toggle';
  shape?: ButtonShapeType;
}

export interface SliderComponent extends ControlComponent {
  type: 'slider';
  orientation: 'horizontal' | 'vertical';
  min: number;
  max: number;
  defaultValue?: number;
}

export interface JoystickComponent extends ControlComponent {
  type: 'joystick';
  // specific joystick properties
}

export interface DPadComponent extends ControlComponent {
  type: 'dpad';
  // specific dpad properties
}

export type AnyControlComponent = ButtonComponent | SliderComponent | JoystickComponent | DPadComponent;


export type CommunicationMethod =
  | 'bluetooth_classic'
  | 'ble'
  | 'wifi_tcp'
  | 'wifi_udp'
  | 'mqtt'
  | 'websocket'
  | 'usb_serial';

export interface CommunicationSettings {
  method: CommunicationMethod | '';
  config: Record<string, string | number | boolean>; // e.g., { ipAddress: "192.168.1.100", port: 8080 }
  periodicSending: boolean;
  sendInterval: number; // in milliseconds
}

export interface Layout {
  id: string;
  name: string;
  components: AnyControlComponent[];
  communicationSettings: CommunicationSettings;
  createdAt: string;
  updatedAt: string;
}

export const COMMUNICATION_METHODS: { value: CommunicationMethod; label: string }[] = [
  { value: 'bluetooth_classic', label: 'Bluetooth Classic' },
  { value: 'ble', label: 'Bluetooth Low Energy (BLE)' },
  { value: 'wifi_tcp', label: 'WiFi TCP' },
  { value: 'wifi_udp', label: 'WiFi UDP' },
  { value: 'mqtt', label: 'MQTT' },
  { value: 'websocket', label: 'WebSocket' },
  { value: 'usb_serial', label: 'USB Serial (OTG)' },
];

export const getDefaultCommunicationSettings = (): CommunicationSettings => ({
  method: '',
  config: {},
  periodicSending: false,
  sendInterval: 100,
});

export const getDefaultControlComponent = (type: ControlComponentType, id: string, index: number): AnyControlComponent => {
  const base = {
    id,
    label: `${type.charAt(0).toUpperCase() + type.slice(1)} ${index + 1}`,
    position: { x: 10, y: 10 + index * 60 }, // Slightly reduce y spacing
    outputIndex: index,
  };
  switch (type) {
    case 'button':
      return { ...base, type: 'button', mode: 'momentary', shape: 'circle', size: { width: 50, height: 50 } };
    case 'slider':
      // Make default slider smaller
      return { ...base, type: 'slider', orientation: 'horizontal', min: 0, max: 255, defaultValue: 128, size: { width: 120, height: 40 } };
    case 'joystick':
       // Make default joystick smaller
      return { ...base, type: 'joystick', size: { width: 100, height: 100 } };
    case 'dpad':
      // Make default DPad smaller
      return { ...base, type: 'dpad', size: { width: 100, height: 100 } };
    default:
      throw new Error('Unknown component type');
  }
};

export const BUTTON_SHAPES: { value: ButtonShapeType; label: string }[] = [
  { value: 'default', label: 'Default (Rounded)' },
  { value: 'pill', label: 'Pill / Oval' },
  { value: 'circle', label: 'Circle (Set W=H)' },
  { value: 'sharp', label: 'Sharp (Rectangle)' },
];

