import type { Station } from './types'
import styles from './index.module.css'

interface Properties {
	stations: Station[]
}

const GeoFootball = ({ stations }: Properties) => {
	return (
		<div className={styles.map}>
			{stations.map((station: Station) => {
				return (
					<ul key={`station-${station.id}`}>
						{Object.entries(station).map(([key, value]) => {
							return (
								<li key={`${key}-${station.id}`}>
									<strong>{key}: </strong>
									<span>{value}</span>
								</li>
							)
						})}
					</ul>
				)
			})}
		</div>
	)
}

export default GeoFootball
