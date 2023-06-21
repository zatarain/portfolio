import { render, screen } from '@testing-library/react'
import { Provider } from 'react-redux'

import { makeStore } from '#store'
import Footer from '.'

describe('<Footer />', () => {
	it('renders the component', () => {
		const store = makeStore()

		render(
			<Provider store={store}>
				<Footer />
			</Provider>
		)

		expect(screen.getByText('Tech Stuff')).toBeInTheDocument()
	})
})
