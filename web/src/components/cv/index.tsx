import { useCV } from '#hooks'

export interface CurriculumVitaeProperties {
	name: string
	emails?: string[],
	phones?: string[],
	websites?: string[],
	statement?: string,
	experiences?: string[],
	qualifications?: string[],
	projects?: string[],
	skills?: string[],
	awards?: string[],
	volunteering?: string[]
}

function CurriculumVitae() {
	const { data } = useCV()
	return (
		<div>
			<h1>{data.name}</h1>
		</div>
	)
}

export default CurriculumVitae
