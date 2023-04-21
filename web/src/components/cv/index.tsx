import { useCV } from '#hooks'

function CurriculumVitae() {
	const { data } = useCV()
	return (
		<div>
			<h1>{data.name}</h1>
		</div>
	)
}

export default CurriculumVitae
