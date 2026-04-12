// This file has been automatically migrated to valid ESM format by Storybook.
import { fileURLToPath } from "node:url";
import * as path, { dirname } from 'path';
import type { StorybookConfig } from '@storybook/nextjs'

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const config: StorybookConfig = {
  stories: ['../src/**/*.mdx', '../src/**/*.stories.@(js|jsx|mjs|ts|tsx)'],

  addons: [
    '@storybook/addon-links',
    '@storybook/addon-onboarding',
    '@storybook/addon-docs'
  ],

  framework: {
    name: '@storybook/nextjs',
    options: {
      nextConfigPath: path.resolve(__dirname, '../next.config.js'),
    },
  }
};
export default config;
