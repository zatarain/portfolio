import { render } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { Provider } from 'react-redux'
import styles from './index.module.css'

import { makeStore } from '#store'
import NavigationBar from '.'

describe('<NavigationBar />', () => {
	it('renders the component correctly with passed name', () => {
		const store = makeStore()

		const { asFragment, getByText } = render(
			<Provider store={store}>
				<NavigationBar name="My Name" />
			</Provider>
		)

		expect(getByText('My Name')).toBeInTheDocument()
		expect(asFragment()).toMatchSnapshot()
	})

	it('adds class name "responsive" when user clicks menu icon', async () => {
		const store = makeStore()
		const user = userEvent.setup()

		const { container } = render(
			<Provider store={store}>
				<NavigationBar name="Test Name" />
			</Provider>
		)
		const dropdown = container.querySelector(`li.${styles.icon} a`)
		expect(dropdown).not.toBeNull()
		const bar = container.querySelector('nav')
		await user.click(dropdown)
		expect(bar).toHaveClass(styles.responsive)
	})
})
