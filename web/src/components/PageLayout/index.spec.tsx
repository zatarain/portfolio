import { jest } from '@jest/globals';
import { render } from '@testing-library/react'
import { Provider } from 'react-redux'
import store from '#store'
import PageLayout from '.'
import Head from 'next/head'

jest.mock('next/font/google', () => {
	return {
		__esModule: true,
		Inter: jest.fn(() => {
			return {
				className: 'my-font',
			}
		}),
	}
})

jest.mock('next/head');

describe('<PageLayout ...>...</PageLayout>', () => {
	it('renders the component correctly with passed name', async () => {
		const head = jest.mocked(Head)

		const { asFragment, getByText } = render(
			<Provider store={store}>
				<PageLayout title="Test title" data={{ name: 'My Name' }}>
					<p>Hello World</p>
				</PageLayout>
			</Provider>
		)

		expect(head).toBeCalled()
		head.mock.lastCall?.map((tag) => tag.children && render(tag.children, { container: document.head }))

		expect(document.title).toBe('My Name - Test title')
		expect(getByText('My Name')).toBeInTheDocument()
		expect(getByText('Hello World')).toBeInTheDocument()
		expect(asFragment()).toMatchSnapshot()
	})
})
