import { render, screen } from '@testing-library/react'
import { Provider } from 'react-redux'

import { makeStore } from '#store'
import NavigationBar from '.'

describe('<NavigationBar />', () => {
	it('renders the component', () => {
		const store = makeStore()

		render(
			<Provider store={store}>
				<NavigationBar name="My Name" />
			</Provider>
		)

		expect(screen.getByText('My Name')).toBeInTheDocument()
	})
})
