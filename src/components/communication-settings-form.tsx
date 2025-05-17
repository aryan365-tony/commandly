
'use client';

import type { CommunicationSettings, CommunicationMethod } from '@/lib/types';
import { COMMUNICATION_METHODS } from '@/lib/types';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Switch } from '@/components/ui/switch';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';

interface CommunicationSettingsFormProps {
  settings: CommunicationSettings;
  onSettingsChange: (settings: CommunicationSettings) => void;
}

export function CommunicationSettingsForm({ settings, onSettingsChange }: CommunicationSettingsFormProps) {
  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value, type, checked } = e.target;
    const newConfig = { ...settings.config };
    if (name in settings.config) {
      newConfig[name] = type === 'checkbox' ? checked : type === 'number' ? parseFloat(value) : value;
    }
    onSettingsChange({ ...settings, config: newConfig });
  };

  const handleFieldChange = (fieldName: keyof CommunicationSettings, value: any) => {
    onSettingsChange({ ...settings, [fieldName]: value });
  };

  const renderConfigFields = () => {
    switch (settings.method) {
      case 'wifi_tcp':
      case 'wifi_udp':
      case 'websocket':
        return (
          <>
            <div className="space-y-1">
              <Label htmlFor="ipAddress">IP Address / Hostname</Label>
              <Input id="ipAddress" name="ipAddress" value={settings.config.ipAddress as string || ''} onChange={handleInputChange} placeholder="e.g., 192.168.1.100 or mydevice.local"/>
            </div>
            <div className="space-y-1">
              <Label htmlFor="port">Port</Label>
              <Input id="port" name="port" type="number" value={settings.config.port as number || ''} onChange={handleInputChange} placeholder="e.g., 8080"/>
            </div>
          </>
        );
      case 'mqtt':
        return (
          <>
            <div className="space-y-1">
              <Label htmlFor="brokerUrl">Broker URL</Label>
              <Input id="brokerUrl" name="brokerUrl" value={settings.config.brokerUrl as string || ''} onChange={handleInputChange} placeholder="e.g., mqtt://broker.hivemq.com"/>
            </div>
            <div className="space-y-1">
              <Label htmlFor="topic">Topic</Label>
              <Input id="topic" name="topic" value={settings.config.topic as string || ''} onChange={handleInputChange} placeholder="e.g., /controller/data"/>
            </div>
            {/* Add username/password if needed */}
          </>
        );
      case 'ble':
        return (
          <>
            <div className="space-y-1">
              <Label htmlFor="serviceUuid">Service UUID</Label>
              <Input id="serviceUuid" name="serviceUuid" value={settings.config.serviceUuid as string || ''} onChange={handleInputChange} placeholder="e.g., 0000xxxx-0000-1000-8000-00805f9b34fb"/>
            </div>
            <div className="space-y-1">
              <Label htmlFor="characteristicUuid">Characteristic UUID</Label>
              <Input id="characteristicUuid" name="characteristicUuid" value={settings.config.characteristicUuid as string || ''} onChange={handleInputChange} placeholder="e.g., 0000yyyy-0000-1000-8000-00805f9b34fb"/>
            </div>
          </>
        );
      case 'bluetooth_classic':
         return (
          <div className="space-y-1">
            <Label htmlFor="macAddress">Device MAC Address</Label>
            <Input id="macAddress" name="macAddress" value={settings.config.macAddress as string || ''} onChange={handleInputChange} placeholder="e.g., 00:11:22:33:FF:EE"/>
          </div>
        );
      case 'usb_serial':
         return (
          <div className="space-y-1">
            <Label htmlFor="baudRate">Baud Rate</Label>
            <Input id="baudRate" name="baudRate" type="number" value={settings.config.baudRate as number || 9600} onChange={handleInputChange} placeholder="e.g., 9600, 115200"/>
          </div>
        );
      default:
        return <p className="text-sm text-muted-foreground">Select a method to see its specific configuration options.</p>;
    }
  };
  
  // Initialize config fields when method changes
  const handleMethodChange = (value: string) => {
    let newConfig = {};
    switch (value as CommunicationMethod) {
      case 'wifi_tcp': case 'wifi_udp': case 'websocket':
        newConfig = { ipAddress: '', port: '' }; break;
      case 'mqtt':
        newConfig = { brokerUrl: '', topic: '' }; break;
      case 'ble':
        newConfig = { serviceUuid: '', characteristicUuid: '' }; break;
      case 'bluetooth_classic':
        newConfig = { macAddress: '' }; break;
      case 'usb_serial':
        newConfig = { baudRate: 9600 }; break;
    }
    onSettingsChange({ ...settings, method: value as CommunicationMethod, config: newConfig });
  };


  return (
    <Card className="shadow-md">
      <CardHeader>
        <CardTitle className="text-lg">Communication Settings</CardTitle>
        <CardDescription>Configure how data is sent from this layout.</CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="space-y-1">
          <Label htmlFor="communicationMethod">Method</Label>
          <Select value={settings.method} onValueChange={handleMethodChange}>
            <SelectTrigger id="communicationMethod">
              <SelectValue placeholder="Select communication method" />
            </SelectTrigger>
            <SelectContent>
              {COMMUNICATION_METHODS.map(method => (
                <SelectItem key={method.value} value={method.value}>{method.label}</SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        {settings.method && renderConfigFields()}

        {settings.method && (
          <>
            <div className="flex items-center space-x-2 pt-2">
              <Switch
                id="periodicSending"
                checked={settings.periodicSending}
                onCheckedChange={(checked) => handleFieldChange('periodicSending', checked)}
              />
              <Label htmlFor="periodicSending">Enable Periodic Data Sending</Label>
            </div>
            {settings.periodicSending && (
              <div className="space-y-1">
                <Label htmlFor="sendInterval">Send Interval (ms)</Label>
                <Input
                  id="sendInterval"
                  type="number"
                  value={settings.sendInterval}
                  onChange={(e) => handleFieldChange('sendInterval', parseInt(e.target.value) || 100)}
                  min="10"
                />
              </div>
            )}
          </>
        )}
      </CardContent>
    </Card>
  );
}
