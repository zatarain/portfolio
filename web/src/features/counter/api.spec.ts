import { fetchCount } from './api'

global.fetch = jest.fn(() =>
	Promise.resolve({
		json: () => Promise.resolve({ data: 4 }),
	})
);

beforeEach(() => {
	fetch.mockClear()
});

describe('', () => {
	it('fetches the counter properly', async () => {
		const counter = await fetchCount(4)

		expect(counter).toEqual({ data: 4 })
		expect(fetch).toHaveBeenCalledTimes(1)
	})
})
