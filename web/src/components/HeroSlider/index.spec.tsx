import { Provider } from 'react-redux'
import store from '#store'
import { render } from '@testing-library/react'
import HeroSlider from '.'

describe('<HeroSlider />', () => {
	it('renders the component correctly with passed name', () => {
		const pictures = [
			{
				id: '1001',
				media_url: 'https://cdn.instagram.com/dummy-01.jpg',
				caption: 'Dummy caption 01',
			},
			{
				id: '1001',
				media_url: 'https://cdn.instagram.com/dummy-01.jpg',
				caption: 'Dummy caption 01',
			},
		]

		const { asFragment } = render(
			<Provider store={store}>
				<HeroSlider images={pictures} />
			</Provider>
		)

		expect(asFragment()).toMatchSnapshot()
	})
})
