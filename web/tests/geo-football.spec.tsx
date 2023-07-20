import { Provider } from 'react-redux'
import store from '#store'
import { render } from '@testing-library/react'
import GeoFootballPage, { getServerSideProps } from '#pages/geo-football'
import { Station } from '#components/GeoFootball/types'

const testData = [
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
	{
		id: 2,
		name: 'Dublin Heuston',
		slug: 'dublin-heuston',
		country: 'IE',
		time_zone: 'Europe/Dublin',
		latitude: 53.34583,
		longitude: -6.29530,
		info_en: 'Irish Trains',
	} as Station,
]

const testClusters = {
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
	IE: [
		{
			id: 2,
			name: 'Dublin Heuston',
			slug: 'dublin-heuston',
			country: 'IE',
			time_zone: 'Europe/Dublin',
			latitude: 53.34583,
			longitude: -6.29530,
			info_en: 'Irish Trains',
		} as Station,
	],
}

global.fetch = jest.fn(() =>
	Promise.resolve({
		ok: true,
		json: () => Promise.resolve(testData),
	})
)

beforeEach(() => {
	fetch.mockClear()
})

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
		Inter: () => ({
			className: 'inter-font-class'
		}),
	}
})

describe('<GeoFootballPage />', () => {
	it('renders the Geo-Football on Rails page', async () => {
		const { findByText, asFragment } = render(
			<Provider store={store}>
				<GeoFootballPage stationsByCountry={testClusters} />
			</Provider>
		)
		expect(await findByText('Geo-Football on Rails')).toBeInTheDocument()
		expect(asFragment()).toMatchSnapshot()
	})
})

describe('getServerSideProps', () => {
	it('fetches spatial data properly from API', async () => {
		const result = await getServerSideProps()

		expect(fetch).toHaveBeenCalledTimes(1)
		expect(result).toEqual({
			props: {
				stationsByCountry: testClusters
			}
		})
	})
})
