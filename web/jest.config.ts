import type { JestConfigWithTsJest } from 'ts-jest/dist/types'

const config: JestConfigWithTsJest = {
  preset: 'ts-jest',
  setupFilesAfterEnv: ['<rootDir>/setupTests.ts'],
  transform: {
    '.+\\.(css|styl|less|sass|scss)$': 'jest-css-modules-transform',
    '.+\\.[tj]sx?$': [
      'ts-jest',
      {
        tsconfig: 'tsconfig.test.json',
        isolatedModules: true,
      }
    ]
  },
  testRegex: '(/src/.*\\.(test|spec))\\.[tj]sx?$',
  testEnvironment: 'jest-environment-jsdom',
  moduleNameMapper: {
    '^#(.*)$': '<rootDir>/src/$1'
  }
}

export default config
