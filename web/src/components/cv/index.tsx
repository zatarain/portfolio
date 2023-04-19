import { useState } from 'react'
// import type { Curriculum } from './slice'
import { useAppDispatch } from '#hooks'
import { getDataAsync } from './slice'

function CurriculumVitae() {
	/**/
	const dispatch = useAppDispatch()
	const [{ value, status }, setter] = useState({
		value: {
			name: ''
		},
		status: 'idle'
	})

	return (
		<div>
			<h1>{value.name}</h1>
			<p>{status}</p>
			<input
				aria-label="Set increment amount"
				value=""
				onChange={(event) => setter({ value: { name: event.target.value }, status: 'failed' })}
			/>
			<button
				onClick={() => dispatch(getDataAsync())}
			>Get Data</button>
			<div>testing hot reaload in component</div>
		</div>
	)
	/**/
}

export default CurriculumVitae
