import renderer from 'react-test-renderer'
import { Provider } from 'react-redux'

import store from '#store'
import Footer from '.'

describe('<Footer />', () => {
	it('renders the component correctly', () => {
		const tree = renderer.create(
			<Provider store={store}>
				<Footer />
			</Provider>
		).toJSON()

		expect(tree).toMatchSnapshot()
	})
})
