
import type { Layout, CommunicationSettings, AnyControlComponent } from './types';

const LAYOUTS_STORAGE_KEY = 'controlCanvasLayouts';

export const getLayouts = (): Layout[] => {
  if (typeof window === 'undefined') {
    return [];
  }
  const layoutsJson = localStorage.getItem(LAYOUTS_STORAGE_KEY);
  return layoutsJson ? JSON.parse(layoutsJson) : [];
};

export const getLayoutById = (id: string): Layout | undefined => {
  return getLayouts().find(layout => layout.id === id);
};

export const saveLayout = (layout: Layout): void => {
  const layouts = getLayouts();
  const existingIndex = layouts.findIndex(l => l.id === layout.id);
  const now = new Date().toISOString();
  
  if (existingIndex > -1) {
    layouts[existingIndex] = { ...layout, updatedAt: now };
  } else {
    layouts.push({ ...layout, createdAt: now, updatedAt: now });
  }
  localStorage.setItem(LAYOUTS_STORAGE_KEY, JSON.stringify(layouts));
};

export const deleteLayout = (id: string): void => {
  const layouts = getLayouts().filter(layout => layout.id !== id);
  localStorage.setItem(LAYOUTS_STORAGE_KEY, JSON.stringify(layouts));
};

export const createNewLayout = (name: string = "New Layout"): Layout => {
  const newId = `layout_${new Date().getTime()}_${Math.random().toString(36).substring(2, 9)}`;
  const now = new Date().toISOString();
  return {
    id: newId,
    name,
    components: [],
    communicationSettings: {
      method: '',
      config: {},
      periodicSending: false,
      sendInterval: 100,
    },
    createdAt: now,
    updatedAt: now,
  };
};
