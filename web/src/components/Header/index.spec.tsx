import { Provider } from 'react-redux'
import store from '#store'
import { render } from '@testing-library/react'
import Header from '.'

describe('<Header />', () => {
	it('renders the component correctly with passed name and pictures', () => {

		const { asFragment } = render(
			<Provider store={store}>
				<Header data={{ name: 'My Name', pictures: [{ id: 'test', media_url: 'test.jpg', caption: 'Test Caption' }] }} />
			</Provider>
		)

		expect(asFragment()).toMatchSnapshot()
	})
})

describe('<Header />', () => {
	it('renders the component correctly with passed name, but no pictures', () => {

		const { asFragment } = render(
			<Provider store={store}>
				<Header data={{ name: 'My Name', pictures: [] }} />
			</Provider>
		)

		expect(asFragment()).toMatchSnapshot()
	})
})

describe('<Header />', () => {
	it('renders the component correctly with passed name and not-defined pictures', () => {

		const { asFragment } = render(
			<Provider store={store}>
				<Header data={{ name: 'My Name' }} />
			</Provider>
		)

		expect(asFragment()).toMatchSnapshot()
	})
})
