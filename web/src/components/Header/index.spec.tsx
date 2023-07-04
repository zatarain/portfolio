import { Provider } from 'react-redux'
import store from '#store'
import { render } from '@testing-library/react'
import Header from '.'

describe('<Header />', () => {
	it('renders the component correctly with passed name', () => {

		const { asFragment } = render(
			<Provider store={store}>
				<Header data={{ name: 'My Name' }} />
			</Provider>
		)

		expect(asFragment()).toMatchSnapshot()
	})
})
