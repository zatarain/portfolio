import { Provider } from 'react-redux'
import store from '#store'
import { render } from '@testing-library/react'
import { jest } from '@jest/globals'
import GeoFootball from '.'
import type { Station } from './types'

jest.mock('react-leaflet')

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
	}
})


describe('<GeoFootball ...>...</GeoFootball>', () => {
	it('renders the component correctly', async () => {
		const stations = {
			GB: [
				{

				},
			],
		}

		const { asFragment } = render(
			<Provider store={store}>
				<GeoFootball stationsByCountry={stations} />
			</Provider>
		)

		expect(asFragment()).toMatchSnapshot()
	})
})
