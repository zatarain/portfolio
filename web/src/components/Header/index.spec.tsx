import { render } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { Provider } from 'react-redux'
import styles from './index.module.css'

import { makeStore } from '#store'
import Header from '.'

describe('<NavigationBar />', () => {
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
