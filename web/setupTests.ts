import '@testing-library/jest-dom'
import { loadEnvConfig } from '@next/env'
import React from 'react'

jest.mock('next/image', () => ({
	__esModule: true,
	default: (props: React.ComponentProps<'img'> & { src: string | { src?: string } }) => {
		const { src, alt, ...rest } = props
		const resolvedSrc = typeof src === 'string' ? src : src?.src || ''
		return React.createElement('img', { src: resolvedSrc, alt, ...rest })
	},
}))

loadEnvConfig(__dirname, true, { info: () => null, error: console.error })
