import { jest } from '@jest/globals';
import { render } from '@testing-library/react'
import { Provider } from 'react-redux'
import { makeStore } from '#store'
import PageLayout from '.'

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

/**
jest.mock('next/head', () => {
	return {
		__esModule: true,
		default: ({ children }: { children: Array<React.ReactElement> }) => {
			return <>{children}</>;
		},
	};
});
/**/

describe('<PageLayout ...>...</PageLayout>', () => {
	it('renders the component correctly with passed name', async () => {
		const store = makeStore()

		const { asFragment, getByText } = render(
			<Provider store={store}>
				<PageLayout title='This is the title' data={{ name: 'My Name' }}>
					<p>Hello World</p>
				</PageLayout>
			</Provider>
		)

		// await waitFor(() => expect(document.title).toBe('This is the title'))
		expect(getByText('My Name')).toBeInTheDocument()
		expect(getByText('Hello World')).toBeInTheDocument()
		expect(asFragment()).toMatchSnapshot()
	})
})
