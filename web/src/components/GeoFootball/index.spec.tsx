import { Provider } from 'react-redux'
import store from '#store'
import { render } from '@testing-library/react'
import { jest } from '@jest/globals'
import userEvent from '@testing-library/user-event'

import GeoFootball from '.'
import type { GroupedStations, Station } from './types'

const events = {
	dblclick: jest.fn()
}

jest.mock('react-leaflet', () => {
	return {
		__esModule: true,
		MapContainer: jest.fn(({ children }) => {
			return (<div onDoubleClick={(event) => events.dblclick(event)} data-testid="test-map">{children}</div>)
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
		useMapEvents: jest.fn(({ dblclick }: typeof events) => {
			events.dblclick = jest.fn((event: any) => dblclick({
				...event,
				latlng: {
					lat: 51.5,
					lng: 1,
				},
			}))
		}),
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

describe('<GeoFootball ...>...</GeoFootball>', () => {
	it('renders the component correctly', async () => {
		const stations = {
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

		const { asFragment, getByTestId } = render(
			<Provider store={store}>
				<GeoFootball stationsByCountry={stations} />
			</Provider>
		)
		expect(asFragment()).toMatchSnapshot()
		expect(getByTestId('test-map')).toBeInTheDocument()
	})

	it('shows form on popup when user double clicks on the map', async () => {
		const user = userEvent.setup()
		const stations = {
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

		const { getByTestId } = render(
			<Provider store={store}>
				<GeoFootball stationsByCountry={stations} />
			</Provider>
		)

		const spy = jest.spyOn(events, 'dblclick')
		await user.dblClick(getByTestId('test-map'))
		expect(spy).toHaveBeenCalledTimes(1)
	})

	it('deletes a Marker when clicks in the delete button', async () => {
		const user = userEvent.setup()
		const stations = {
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

		global.fetch = jest.fn(() => Promise.resolve({ ok: true }))

		const { getByRole, getByText } = render(
			<Provider store={store}>
				<GeoFootball stationsByCountry={stations} />
			</Provider>
		)

		const popup = getByRole('note')
		expect(popup).toBeInTheDocument()

		const deleteMarker = getByText('Delete')
		await user.click(deleteMarker)
		expect(fetch).toHaveBeenCalledTimes(1)

		const [[url, { headers, method }]] = fetch.mock.calls
		expect(url).toMatch(/\/stations\/1/)
		expect(method).toBe('DELETE')
		expect(headers).toEqual(expect.objectContaining({
			'Content-Type': 'application/json',
		}))
		expect(stations).toEqual({ GB: [] })
		expect(popup).not.toBeInTheDocument()
	})
})
