import type { Station } from './types'
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet'
import styles from './index.module.css'

interface Properties {
	stations: Station[]
}

const GeoFootball = ({ stations }: Properties) => {
	// var map = L.map('map').setView([51.505, -0.09], 13);
	return (
		<MapContainer className={styles.map} center={[51.505, -0.09]} zoom={13} scrollWheelZoom={false}>
			<TileLayer
				attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
				url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
			/>
			{stations.map((station: Station) =>
				<Marker key={station.id} position={[station.latitude, station.longitude]}>
					<Popup>{station.name}</Popup>
				</Marker>
			)}

		</MapContainer>
	)
}

export default GeoFootball
