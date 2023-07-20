import { Provider } from 'react-redux'
import store from '#store'
import { render } from '@testing-library/react'
import { jest } from '@jest/globals'
import userEvent from '@testing-library/user-event'

import MapForm from './form'
import type { GroupedStations, Station } from './types'

jest.mock('react-leaflet', () => {
	return {
		__esModule: true,
		MapContainer: jest.fn(({ children }) => {
			return (<>{children}</>)
		}),
		TileLayer: jest.fn(({ children }) => {
			return (<>{children}</>)
		}),
		Marker: jest.fn(({ children }) => {
			return (<>{children}</>)
		}),
		Popup: jest.fn(({ children }) => {
			return (<>{children}</>)
		}),
		useMapEvents: jest.fn(),
	}
})

jest.mock('react-leaflet-cluster', () => {
	return {
		__esModule: true,
		default: jest.fn(({ children }) => {
			return (<>{children}</>)
		}),
	}
})

jest.mock('next/font/google', () => {
	return {
		__esModule: true,
		Noto_Color_Emoji: jest.fn(() => {
			return {
				className: 'my-font',
			}
		}),
	}
})

describe('<MapForm ...>...</MapForm>', () => {
	it('renders the component correctly', async () => {
		const clusters = {
			GB: [
				{
					id: 1,
					name: 'Canary Wharf',
					slug: 'canary-wharf',
					country: 'GB',
					time_zone: 'Europe/London',
					latitude: 51.50361,
					longitude: -0.01861,
					info_en: 'London Underground Station',
				} as Station,
			],
		} as GroupedStations

		const setClusters = jest.fn()

		const { asFragment } = render(
			<Provider store={store}>
				<MapForm clusters={clusters} setClusters={setClusters} />
			</Provider>
		)

		expect(asFragment()).toMatchSnapshot()
	})

	it('adds a new Marker when submit is successful', async () => {
		const user = userEvent.setup()
		const clusters = {
			GB: [
				{
					id: 1,
					name: 'Canary Wharf',
					slug: 'canary-wharf',
					country: 'GB',
					time_zone: 'Europe/London',
					latitude: 51.50361,
					longitude: -0.01861,
					info_en: 'London Underground Station',
				} as Station,
			],
		} as GroupedStations

		const setClusters = jest.fn()
		const data = {
			name: 'Greenwich',
			country: 'GB',
			time_zone: 'Europe/London',
			latitude: 51.478,
			longitude: 0.00000,
			info_en: 'London Underground Station',
		}
		global.fetch = jest.fn(() => Promise.resolve({
			ok: true,
			json: jest.fn(() => Promise.resolve({ id: 2, ...data }))
		}))

		const { getByLabelText, getByText } = render(
			<Provider store={store}>
				<MapForm clusters={clusters} setClusters={setClusters} />
			</Provider>
		)

		await user.type(getByLabelText(/Name/), data.name)
		await user.type(getByLabelText(/Country/), data.country)
		await user.type(getByLabelText(/Additional information/), data.info_en)

		const save = getByText('Save')
		await user.click(save)
		expect(fetch).toHaveBeenCalledTimes(1)
		expect(setClusters).toHaveBeenCalledTimes(1)

		const [[url, { body, headers, method }]] = fetch.mock.calls
		expect(url).toMatch(/\/stations/)
		expect(method).toBe('POST')
		expect(headers).toEqual(expect.objectContaining({
			'Content-Type': 'application/json',
		}))
		expect(JSON.parse(body)).toEqual(expect.objectContaining(data))
		const [[newClusters]] = setClusters.mock.calls
		expect(newClusters).toEqual({ GB: [...clusters.GB, { id: 2, ...data }] })
	})

	it('shows error message when submit fails with bad request status', async () => {
		const user = userEvent.setup()
		const clusters = { GB: [] } as GroupedStations

		const setClusters = jest.fn()
		global.fetch = jest.fn(() => Promise.resolve({
			ok: false,
			status: 400,
			json: jest.fn(() => Promise.resolve({ name: 'can not be blank' }))
		}))

		const { getByLabelText, getByText } = render(
			<Provider store={store}>
				<MapForm clusters={clusters} setClusters={setClusters} />
			</Provider>
		)

		await user.type(getByLabelText(/Name/), '  ')

		const save = getByText('Save')
		await user.click(save)
		expect(fetch).toHaveBeenCalledTimes(1)
		expect(setClusters).not.toHaveBeenCalled()

		const [[url, { headers, method }]] = fetch.mock.calls
		expect(url).toMatch(/\/stations/)
		expect(method).toBe('POST')
		expect(headers).toEqual(expect.objectContaining({
			'Content-Type': 'application/json',
		}))
		expect(getByText(/can not be blank/i)).toBeInTheDocument()
	})

	it('logs the error message when submit fails with HTTP 500 status', async () => {
		const user = userEvent.setup()
		const clusters = { GB: [] } as GroupedStations

		const setClusters = jest.fn()
		global.fetch = jest.fn(() => Promise.resolve({
			ok: false,
			status: 500,
			text: jest.fn(() => Promise.resolve('Internal Server Error'))
		}))

		console.error = jest.fn()

		const { getByLabelText, getByText } = render(
			<Provider store={store}>
				<MapForm clusters={clusters} setClusters={setClusters} />
			</Provider>
		)

		await user.type(getByLabelText(/Name/), '  ')

		const save = getByText('Save')
		await user.click(save)
		expect(fetch).toHaveBeenCalledTimes(1)
		expect(setClusters).not.toHaveBeenCalled()

		const [[url, { headers, method }]] = fetch.mock.calls
		expect(url).toMatch(/\/stations/)
		expect(method).toBe('POST')
		expect(headers).toEqual(expect.objectContaining({
			'Content-Type': 'application/json',
		}))
		expect(console.error).toBeCalledTimes(1)
		const [[message]] = console.error.mock.calls
		expect(message).toMatch(/Internal Server Error/)
	})
})
