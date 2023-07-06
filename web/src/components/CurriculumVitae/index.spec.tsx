import { render } from '@testing-library/react'
import CurriculumVitae from '.'

describe('<CurriculumVitae />', () => {
	it('renders the component', () => {
		const data = {
			name: 'My Test Name',
			statement: 'Test statement paragraph',
			education: [
				{
					school: 'dummy school',
					grade: 'BSc Dummy Career',
					start: 2019,
					end: 2021,
					gpa: 90,
					subjects: [
						'hello',
						'world',
					],
				},
				{
					school: 'dummy research centre',
					grade: 'MSc Dummy Career',
					thesis: 'Dummy Thesis Topic',
					start: 2021,
					end: 2023,
					gpa: 95,
					subjects: [
						'hello master',
						'world master',
					],
				},
			],
			experience: [
				{
					role: 'dummy role',
					type: 'full-time',
					company: 'dummy company',
					city: 'dummy city',
					country: 'dummy country',
					start: '10/2021',
					end: '10/2022',
					contributions: 'dummy contributions paragraph',
				},
				{
					role: 'dummy role intern',
					type: 'part-time',
					company: 'same company',
					city: 'another city',
					country: 'same country',
					start: '06/2021',
					end: '09/2021',
					contributions: 'dummy contributions paragraph as intern',
				},
			],
			projects: [
				{
					title: 'Dummy Project 01',
					type: 'thesis',
					start: '08/2013',
					end: '11/2014',
					description: 'Dummy description paragraph 01',
				},
				{
					title: 'Dummy Project 02',
					type: 'personal',
					duration: 'Spring 2023',
					description: 'Dummy description paragraph 02',
				},
			],
			awards: [
				'Dummy Award 01',
				'Dummy Award 02',
			],
			leadership: 'Test leadership paragraph',
			volunteering: 'Test volunteering paragraph',
			pictures: [
				{
					id: '1001',
					media_url: 'https://cdn.instagram.com/dummy-01.jpg',
					caption: 'Dummy caption 01',
				},
				{
					id: '1001',
					media_url: 'https://cdn.instagram.com/dummy-01.jpg',
					caption: 'Dummy caption 01',
				},
			],
		}
		const { asFragment, getByText } = render(<CurriculumVitae data={data} />)

		expect(getByText('Test statement paragraph')).toBeInTheDocument()
		expect(asFragment()).toMatchSnapshot()
	})
})
