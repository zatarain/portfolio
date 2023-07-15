import { Provider } from 'react-redux'
import store from '#store'
import { jest } from '@jest/globals';
import { render } from '@testing-library/react'
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

	it('renders only NavigationBar and Footer when hero is false', () => {
		const head = jest.mocked(Head)

		const { asFragment, getByText } = render(
			<Provider store={store}>
				<PageLayout title="Test title" data={{ name: 'My Name' }} hero={false}>
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

	it('renders name same as title when data is missing', () => {
		const head = jest.mocked(Head)

		const { asFragment, getByText } = render(
			<Provider store={store}>
				<PageLayout title="Test title" hero={false}>
					<p>Hello World</p>
				</PageLayout>
			</Provider>
		)

		expect(head).toBeCalled()
		head.mock.lastCall?.map((tag) => tag.children && render(tag.children, { container: document.head }))

		expect(document.title).toBe('Test title')
		expect(getByText('Test title')).toBeInTheDocument()
		expect(getByText('Hello World')).toBeInTheDocument()
		expect(asFragment()).toMatchSnapshot()
	})
})
