import { render } from '@testing-library/react'
import { Provider } from 'react-redux'

import { makeStore } from '#store'
import Header from '.'

describe('<Header />', () => {
	it('renders the component correctly with passed name', () => {
		const store = makeStore()

		const { asFragment, getByText } = render(
			<Provider store={store}>
				<Header data={{ name: 'My Name' }} />
			</Provider>
		)

		expect(getByText('My Name')).toBeInTheDocument()
		expect(asFragment()).toMatchSnapshot()
	})
})
