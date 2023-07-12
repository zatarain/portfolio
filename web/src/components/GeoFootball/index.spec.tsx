import { Provider } from 'react-redux'
import store from '#store'
import { render } from '@testing-library/react'
import GeoFootball from '.'
import type { Station } from './types';

describe('<GeoFootball ...>...</GeoFootball>', () => {
	it('renders the component correctly', async () => {
		const stations = [
			{

			}
		] as Station[]

		const { asFragment } = render(
			<Provider store={store}>
				<GeoFootball stations={stations} />
			</Provider>
		)

		expect(asFragment()).toMatchSnapshot()
	})
})
