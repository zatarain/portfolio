import { Provider } from 'react-redux'
import store from '#store'
import { render } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import NavigationBar from '.'
import styles from './index.module.css'

window.print = jest.fn()

beforeEach(() => {
	window.print.mockClear()
});

describe('<NavigationBar />', () => {
	it('renders the component correctly with passed name', () => {
		const { asFragment, getByText } = render(
			<Provider store={store}>
				<NavigationBar name="My Name" />
			</Provider>
		)

		expect(getByText('My Name')).toBeInTheDocument()
		expect(asFragment()).toMatchSnapshot()
	})

	it('adds/removes class name "responsive" when user clicks on dropdown menu', async () => {
		const user = userEvent.setup()

		const { getByRole } = render(
			<Provider store={store}>
				<NavigationBar name="Test Name" />
			</Provider>
		)

		const bar = getByRole('menubar')
		const dropdown = getByRole('menuitemcheckbox')

		expect(bar).not.toHaveClass(styles.responsive)

		await user.click(dropdown)
		expect(bar).toHaveClass(styles.responsive)

		await user.click(dropdown)
		expect(bar).not.toHaveClass(styles.responsive)
	})

	it('shows print dialog when user clicks on Download button', async () => {
		const user = userEvent.setup()

		const { getByText } = render(
			<Provider store={store}>
				<NavigationBar name="Test Name" />
			</Provider>
		)

		const download = getByText('Download')

		await user.click(download)
		expect(window.print).toHaveBeenCalled()
	})

	test.each([
		'Experience',
		'Education',
		'Academic Projects',
		'Leadership',
	])('<Link ...>%s</Link> closes the menu when is open in responsive mode', async (link) => {
		const user = userEvent.setup()

		const { getByText, getByRole } = render(
			<Provider store={store}>
				<NavigationBar name="Test Name" />
			</Provider>
		)

		const bar = getByRole('menubar')
		const dropdown = getByRole('menuitemcheckbox')

		expect(bar).not.toHaveClass(styles.responsive)

		await user.click(dropdown)
		expect(bar).toHaveClass(styles.responsive)

		await user.click(getByText(link))
		expect(bar).not.toHaveClass(styles.responsive)
	})
})
