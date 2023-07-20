import { Provider } from 'react-redux'
import store from '#store'
import { render } from '@testing-library/react'
import Loading from './loading'

describe('<Loading />', () => {
	it('renders the component correctly with passed name', () => {

		const { asFragment } = render(
			<Provider store={store}>
				<Loading text='Hello World' />
			</Provider>
		)

		expect(asFragment()).toMatchSnapshot()
	})
})
