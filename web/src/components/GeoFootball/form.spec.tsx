import { Provider } from 'react-redux'
import store from '#store'
import { render } from '@testing-library/react'
import { jest } from '@jest/globals'
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
})
